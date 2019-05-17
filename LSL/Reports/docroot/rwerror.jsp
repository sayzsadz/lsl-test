<html>
<body>
<%@ page isErrorPage="true" import="java.io.*,java.util.*" %>
<h1>Reports Error Page</h1>
<br>
<%= new java.util.Date() %>
<br>
<b><%= exception.toString() %></b>
<%
{
  if (exception instanceof oracle.reports.RWException)
  {
    oracle.reports.RWException rwe = (oracle.reports.RWException)exception;
    for (int i = 0; i < rwe.errorChain.length; i++)
    {
      out.println(rwe.errorChain[i].moduleName + "-" + 
                  rwe.errorChain[i].errorCode + ":" + 
                  rwe.errorChain[i].errorString);
      out.println("<br>");
    }
  }

  StringWriter sw = new StringWriter();
  PrintWriter pw = new PrintWriter(sw);
  exception.printStackTrace(pw);
  pw.close();
  out.println("<pre>");
  out.println(sw.toString());
  out.println("</pre>");
}
%>
</body>
</html>
