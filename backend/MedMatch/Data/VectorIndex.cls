Class MedMatch.Data.VectorIndex Extends %Persistent
{

Property ResourceID As %String [ Required ];

Property ResourceType As %String;

Property NoteVector As %Vector(DATATYPE = "FLOAT", LEN = 384);

Property ConditionText As %String(MAXLEN = 1000);

Index ResIdx On (ResourceType, ResourceID) [ Unique ];

ClassMethod SaveVector(type As %String = "", id As %String = "", text As %String = "") As %Status
{
    If type="" {
        $$$ThrowOnError($$$ERROR($$$GeneralError, "Resource type is required"))
    }
    If id="" {
        $$$ThrowOnError($$$ERROR($$$GeneralError, "Resource id is required"))
    }
    Set vectorList = ##class(MedMatch.Engine).GetVector(text)
    Set vectorJson = vectorList.%ToJSON()

    Set sql = "INSERT INTO MedMatch_Data.VectorIndex (ResourceType, ResourceID, NoteVector,ConditionText) " _
             "VALUES (?, ?, TO_VECTOR(?, FLOAT, 384),?)"
    Set rset = ##class(%SQL.Statement).%ExecDirect(, sql, type, id, vectorList,text)
    If rset.%sqlcode {
        $$$ThrowSQLCODE(rset.%SQLCODE,rset.%Message)
    }
    Return $$$OK
}

Storage Default
{
<Data name="VectorIndexDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ResourceID</Value>
</Value>
<Value name="3">
<Value>ResourceType</Value>
</Value>
<Value name="4">
<Value>NoteVector</Value>
</Value>
<Value name="5">
<Value>Condition</Value>
</Value>
<Value name="6">
<Value>ConditionText</Value>
</Value>
</Data>
<DataLocation>^MedMatch.Data.VectorIndexD</DataLocation>
<DefaultData>VectorIndexDefaultData</DefaultData>
<IdLocation>^MedMatch.Data.VectorIndexD</IdLocation>
<IndexLocation>^MedMatch.Data.VectorIndexI</IndexLocation>
<StreamLocation>^MedMatch.Data.VectorIndexS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
