Class MedMatch.Engine Extends %RegisteredObject
{

ClassMethod Search(text As %String = "pain")
{
    Set results = ..FindSimilarPatients(text)
    Quit results
}

ClassMethod InitializeVectors() As %Status
{
    Set status = $$$OK
    Try {
        Set bundle = ##class(MedMatch.FHIR.Config).GetResources("Condition")

        If bundle.Status '= 200 {
            $$$ThrowOnError($$$ERROR($$$GeneralError, "Failed to retrieve conditions from FHIR server and status is "_bundle.StatusCode ))
        }

        If '$IsObject(bundle.Json) {
            $$$ThrowOnError($$$ERROR($$$GeneralError, "Bundle JSON is not an object"))
        }

        If (bundle.Json.%Size() = 0) {
            $$$ThrowOnError($$$ERROR($$$GeneralError, "Bundle JSON is empty"))
        }
        If '$IsObject(bundle.Json.entry) {
            $$$ThrowOnError($$$ERROR($$$GeneralError, "Bundle JSON does not contain 'entry' array"))
        }
        If (bundle.Json.entry.%Size() = 0) {
            $$$ThrowOnError($$$ERROR($$$GeneralError, "Bundle 'entry' array is empty"))
        }
        Set iter = bundle.Json.entry.%GetIterator()
        While iter.%GetNext(.key, .entry) {
            Set resource = entry.resource
            Set id = resource.id
            Set text = resource.code.text
            If (text '= "") {
                Set sc = ##class(MedMatch.Data.VectorIndex).SaveVector("Condition", id, text)
            }
        }
    }
    Catch ex {
        Set status = ex.AsStatus()
    }
    Return status
}

ClassMethod FindSimilarPatients(queryText As %String, limit As %Integer = 500) As %DynamicArray
{
    Set results = []
    Set queryVector = ..GetVector(queryText)
    Set sql = "SELECT TOP ? idx.ResourceID, idx.ResourceType, VECTOR_COSINE(idx.NoteVector, TO_VECTOR(?)) AS Similarity,"_
     "cond.Key, cond.patient_Reference, pat.value As patientName FROM MedMatch_Data.VectorIndex idx JOIN HSFHIR_X0001_S.Condition cond ON idx.ResourceID = cond._id_Value"_
     " JOIN HSFHIR_X0001_S_Patient.name pat ON pat.Key = cond.patient_Reference "_
     " GROUP BY idx.ResourceID "_
     "  ORDER BY Similarity DESC"

    Set rset = ##class(%SQL.Statement).%ExecDirect(, sql, limit, queryVector)

    If rset.%sqlcode {
        $$$ThrowSQLCODE(rset.%SQLCODE,rset.%Message)
    }

    While rset.%Next() {
        Do results.%Push(
            {
            "patientId": (rset.%Get("patient_Reference")),
            "condition": (rset.%Get("Key")),
            "similarity": ($Normalize(rset.%Get("Similarity"), 4)),
            "resourceId": (rset.%Get("ResourceID")),
            "patientName": (rset.%Get("patientName"))
            }
        )
    }

    Return results
}

ClassMethod GetVector(text As %String) As %Vector [ Language = python ]
{
    import sys, os, json, iris
    import torch
    import torch.nn.functional as F

    p_path = "/usr/irissys/mgr/python"
    if p_path not in sys.path: sys.path.insert(0, p_path)

    try:
        from transformers import AutoTokenizer
        try:
            from optimum_onnx import ORTModelForFeatureExtraction
        except ImportError:
            from optimum.onnxruntime import ORTModelForFeatureExtraction

        model_id = "sentence-transformers/all-MiniLM-L6-v2"

        if 'MM_MODEL' not in globals():
            globals()['MM_TK'] = AutoTokenizer.from_pretrained(model_id)
            globals()['MM_MODEL'] = ORTModelForFeatureExtraction.from_pretrained(
                model_id, export=True, provider="CPUExecutionProvider"
            )

        # 1. Tokenize
        encoded_input = globals()['MM_TK'](text, padding=True, truncation=True, return_tensors='pt')

        # 2. Inference
        with torch.no_grad():
            outputs = globals()['MM_MODEL'](**encoded_input)

        last_hidden_state = outputs.last_hidden_state
        attention_mask = encoded_input['attention_mask']

        # 3. Masked Mean Pooling
        input_mask_expanded = attention_mask.unsqueeze(-1).expand(last_hidden_state.size()).float()
        sum_embeddings = torch.sum(last_hidden_state * input_mask_expanded, 1)
        sum_mask = torch.clamp(input_mask_expanded.sum(1), min=1e-9)
        pooled_output = sum_embeddings / sum_mask

        # 4. FINAL STEP: L2 Normalization (Mandatory for this model)
        normalized_output = F.normalize(pooled_output, p=2, dim=1)

        vector = normalized_output.squeeze().tolist()
        return iris.cls("%Library.DynamicArray")._FromJSON(json.dumps(vector))

    except Exception as e:
        return f"ERROR: {str(e)}"
}

}
