Class MedMatch.REST.Dispatch Extends MedMatch.REST.Base
{

Parameter HandleCorsRequest = 1;

Parameter CHARSET = "utf-8";

Parameter UseSession As BOOLEAN = 1;

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
   <Route Url="/search" Method="GET" Call="StartSearch" Cors="true"/>
</Routes>
}

ClassMethod StartSearch() As %Status
{
    Try {
        Set %response.ContentType = "application/json"
        Set text = %request.Get("text")
        If text="" {
            Do ..SetStatusCode(400)
            Set response =  {"status": "error", "message": "Query parameter 'text' is required"}
        } Else {
            Set response = ##class(MedMatch.Engine).Search(text)
            Do ..SetStatusCode(200)
        }
    } Catch (ex) {
        Set results = {"status": "error", "message": (ex.DisplayString())}
        Do ..SetStatusCode(500)
    }
    Do ..WriteResponse(response)
    Return $$$OK
}

}
