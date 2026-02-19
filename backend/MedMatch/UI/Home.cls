Class MedMatch.UI.Home Extends %CSP.Page
{

Parameter Title As STRING;

ClassMethod OnPage() As %Status
{
	Do ..OnPageCSPROOT()
	Quit 1
}

ClassMethod OnPageCSPROOT() As %Boolean
{
	Do ..OnPageHTML()
}

ClassMethod OnPageHTML() As %Boolean
{
	Write "<html>"
	Write !
	Do ..OnPageHEAD()
	Do ..OnPageBODY()
	Write !,"</html>"
	Return $$$OK
}

ClassMethod OnPageHEAD() As %Boolean
{
	Write "<head>",!
	Write !,"<title>"_..#Title_"</title>",!
	Write "<style>",!
	Do ..LoadCSS()
	Write "</style>",!
	Write "</head>",!
	Write ..HyperEventHead(0,0)
	Return $$$OK
}

ClassMethod OnPageBODY() As %Boolean
{
	Do ..RenderScreen()
	Return $$$OK
}

/// Override this method to render your screens in UI
ClassMethod RenderScreen()
{
	Do ..OnRenderScreen()
	Do ..Script()
}

ClassMethod Script()
{
}

ClassMethod LoadCSS()
{
	Set obj = ##class(%Dictionary.CompiledXData).%OpenId($ClassName()_"||Style")
	Return:(obj = "") $$$OK
	Set xdata = obj.Data
	Set status = ##class(%XML.TextReader).ParseStream(xdata, .textreader)
	While textreader.Read() { If (textreader.NodeType="chars") { Write textreader.Value } }
	Return $$$OK
}

ClassMethod GetErrorText(pStatus) [ CodeMode = expression ]
{
$System.Status.GetErrorText(pStatus)
}

ClassMethod OnRenderScreen() As %Status
{

   &HTML<
<!DOCTYPE html>
<html>
<head>
    <title>Simple Input Example</title>
    <script language="javascript">
        function handleSubmit() {
            var inputValue = document.getElementById("myInput").value;
            var d = #server(..GetVect(inputValue))#;
            alert("You entered: " + inputValue + " and the server returned: " + d);
        }
    </script>
</head>
<body>

    <h2>Simple Form</h2>

    <input type="text" id="myInput" placeholder="Type something here">
    <button onclick="handleSubmit()">Submit</button>

</body>
</html>

   >
    Quit $$$OK
}

ClassMethod GetVect(ptx)
{
     Set results = ##class(MedMatch.Engine).FindSimilarPatients(ptx)
     Return results
}

}
