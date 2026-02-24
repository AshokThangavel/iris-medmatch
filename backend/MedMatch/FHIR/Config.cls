Class MedMatch.FHIR.Config Extends %RegisteredObject
{

ClassMethod Setup() As %Status
{
    Try {
         Do ..CreateInstance()
    } Catch(ex) {
        Set ^medmatch.fhirsetup = ex.DisplayString()
        Write "Error installing FHIR Server: "_ex.DisplayString()
    }
}

ClassMethod CreateWebApp()
{
    New $Namespace
    Set $Namespace = "%SYS"
    Set props("Path") = "/medmatch/api"
    Set props("NameSpace") = "FHIRAPP"
    Set props("Description") = "MedMatch analyzer API"
    Set props("DispatchClass") = "MedMatch.REST.Dispatch"
    Set props("AutheEnabled") = 96
    Set props("MatchRoles")=":%All"
    Set props("CookiePath")="/medmatch/api/"
    Set props("Enabled")=1
    Do ##class(Security.Applications).Create("/medmatch/api", .props)
}

/// Create a FHIR server instance for testing FHIR profiles
ClassMethod CreateInstance()
{
    Set strategyClass = "HS.FHIRServer.Storage.JsonAdvSQL.InteractionsStrategy"
    Set appKey = "/csp/healthshare/medmatch/fhir/r4"
    Set metadataPackages = $ListBuild("hl7.fhir.r4.core@4.0.1","hl7.fhir.us.core@3.1.0")
    Do ##class(HS.FHIRServer.Installer).InstallInstance(appKey,strategyClass, metadataPackages,,"Med Match service",0)
}

/// Import a FHIR packages (profiles,serachparameters) from local directory
/// Parameter Definition
/// pPackage - Local directory path of the FHIR package to import
ClassMethod ImportPackage(pPackageDir As %String = "") As %Status [ Internal ]
{
    Return:pPackageDir="" ""
    Set pPackageDir = $ListBuild(pPackageDir)
    Set status = ##class(HS.FHIRMeta.Load.NpmLoader).importPackages(pPackageDir)
    If $$$ISERR(status) {
        Write status
    }
    Quit $$$OK
}

ClassMethod InitilizeFHIRCondVect()
{
     Try {
        $$$ThrowOnError(##class(MedMatch.Engine).InitializeVectors())
    }
    Catch ex {
        Write "Error initializing vectors: "_ex.DisplayString()
    }
}

ClassMethod PostResources(pResourceType As %String, pResource As %String, pResponse As HS.FHIRServer.API.Data.Response) As %Status
{
    Set url = "/csp/healthshare/medmatch/fhir/r4"
    #dim fhirService As HS.FHIRServer.Service = ##class(HS.FHIRServer.Service).EnsureInstance(url)
    Set request = ##class(HS.FHIRServer.API.Data.Request).%New()
    Set request.RequestPath = "/"_pResourceType
    Set request.RequestMethod = "POST"
    Set request.Json = {}.%FromJSON(pResource)
    Do fhirService.DispatchRequest(request, .pResponse)
}

ClassMethod GetResources(pResourceType As %String, Id As %String = "") As %Status
{
    Set url = "/csp/healthshare/medmatch/fhir/r4"
    Set fhirService = ##class(HS.FHIRServer.Service).EnsureInstance(url)
    Set request = ##class(HS.FHIRServer.API.Data.Request).%New()
    If Id="" {
         Set request.RequestPath = "/"_pResourceType
    }
    Else {
        Set request.RequestPath = "/"_pResourceType_"/"_Id
    }
    Set request.RequestMethod = "GET"
    Do fhirService.DispatchRequest(request, .response)
    Return response
}

ClassMethod SeedTestData() As %Status
{
    Set conditions = $ListBuild("Hypertension", "Type 2 Diabetes", "Acute Bronchitis", "Chronic Back Pain", "Seasonal Allergies", "Asthma", "Generalized Anxiety Disorder", "Hyperlipidemia", "Vitamin D Deficiency", "Gastroesophageal Reflux Disease")
    Set firstNames = $ListBuild("John", "Jane", "Alice", "Bob", "Charlie", "Diana", "Edward", "Fiona", "George", "Hannah")
    Set lastNames = $ListBuild("Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis", "Rodriguez", "Martinez")

    Set sc = $$$OK

    For i=1:1:50 {
        // 1. Pick random data
        Set fName = $List(firstNames, $Random(10)+1)
        Set lName = $List(lastNames, $Random(10)+1)
        Set condText = $List(conditions, $Random(10)+1)

        // 2. Create Patient JSON Object
        Set pObj = {}
        Set pObj.resourceType = "Patient"
        Do pObj.%Set("active",1,"boolean")
        Set pName = {}
        Set name = [(fName)]
        Set pName."given"=name
        Set pName.family = lName
        Set pObj."name"= [ (pName) ]
        Set pObj.gender = $Select($Random(2):"male", 1:"female")
        Do ..PostResources("Patient", pObj.%ToJSON(), .pResponse)

        If pResponse.Id'="" {
            // Extract the new Patient ID (e.g., "1") from the response
            // This depends on how your PostResources is written,
            // usually it's in the Location header or a JSON body
            Set patientId = pResponse.Id

            // 4. Create Condition JSON Object linked to that Patient
            Set cObj = {}
           Set cObj.resourceType = "Condition"
            Set cObj.subject = { "reference": ("Patient/"_patientId) }
            Set cObj.code = {
                "coding": [ {
                    "system": "http://snomed.info/sct",
                    "display": (condText)
                } ],
                "text": (condText)
            }
            Set cObj.clinicalStatus = {
                "coding": [ {
                    "system": "http://terminology.hl7.org/CodeSystem/condition-clinical",
                    "code": "active"
                } ]
            }

            // 5. Post Condition
            Do ..PostResources("Condition", cObj.%ToJSON(), .cResponse)
        }

        If (i # 10 = 0) Write i_" resources created...",!
    }

    Write "100 test patients and their conditions created successfully!",!
    Do ..LoadSampleResourcesOnFHIRRepo()
    Write !,"Initialzing fhir vectors..."
    Do ..InitilizeFHIRCondVect()
     Write !,"fhir vectors initialized."
    Return $$$OK
}

ClassMethod LoadSampleResourcesOnFHIRRepo()
{
    Set patient = {"resourceType":"Patient", "name":[{"given":["John"], "family":"Doe"}]}.%ToJSON()
    Do ..PostResources("Patient", patient,.response)
    If response.Id'="" {
        Set condition = {"resourceType":"Condition", "subject":{"reference":("Patient/"_response.Id)}, "code":{"text":"Acute respiratory distress and chest pain"}}.%ToJSON()
        Do ..PostResources("Condition", condition, .response)
    }
}

}
