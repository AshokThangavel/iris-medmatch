Class MedMatch.REST.Dispatch Extends MedMatch.REST.Base
{

Parameter HandleCorsRequest = 1;

Parameter CHARSET = "utf-8";

Parameter UseSession As BOOLEAN = 1;

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
   <Route Url="/search" Method="GET" Call="StartSearch" Cors="true"/>
   <Route Url="/condition-vectors" Method="POST" Call="GenerateConditionVector" Cors="true"/>
</Routes>
}

ClassMethod StartSearch() As %Status
{
    Try {
        Set text = %request.Get("text")
        If text="" {
            Do ..SetStatusCode(..#HTTP400BADREQUEST)
            Set response =  ..GetStatusError("Query parameter 'text' is required")
            Quit
        } Else {
            Set response = ##class(MedMatch.Engine).Search(text)
            Do ..SetStatusCode(..#HTTP200OK)
        }
    } Catch (ex) {
        Set results = ..GetStatusError(ex)
        Do ..SetStatusCode(..#HTTP500INTERNALSERVERERROR)
    }
    Do ..WriteResponse(response)
    Return $$$OK
}

ClassMethod GenerateConditionVector() As %Status
{
    Try {
        Set payload = ..GetContent()
        If '$IsObject(payload) {
            Do ..SetStatusCode(..#HTTP400BADREQUEST)
            Set response =  ..GetStatusError("Payload is not json object")
            Quit
        }
        Do ##class(MedMatch.Engine).SaveConditionVector(payload)
        Set response = ..GetStatusOK()
        Do ..SetStatusCode(..#HTTP200OK)

    } Catch (ex) {
        Set response = ..GetStatusError(ex)
        Do ..SetStatusCode(..#HTTP500INTERNALSERVERERROR)
    }
    Do ..WriteResponse(response)
    Return $$$OK
}

}
