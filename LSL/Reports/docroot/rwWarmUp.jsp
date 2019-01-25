<!--
 This file is use to warm start the internal web server in the Reports Builder.
 It's executed as soon as the webserver is ready to service request.

 It currently contains:
   - The "session" page directive is used to start up OC4J's session-id 
     seed generator. Once startup, the next session-full JSP request takes
     significantly faster to service. 

 NOTE:
   Only put Builder related initializations in this file.
-->
<%@ page session="true" %>
<HTML> 
  <BODY> 
    <%= new java.util.Date() %>
  </BODY> 
</HTML> 
