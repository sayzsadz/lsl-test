
import oracle.jsp.runtime.*;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.jsp.*;


public class _rwWarmUp extends com.orionserver.http.OrionHttpJspPage {

  public final String _globalsClassName = null;

  // ** Begin Declarations


  // ** End Declarations

  public void _jspService(HttpServletRequest request, HttpServletResponse response) throws java.io.IOException, ServletException {

    response.setContentType( "text/html;charset=ISO-8859-1");
    /* set up the intrinsic variables using the pageContext goober:
    ** session = HttpSession
    ** application = ServletContext
    ** out = JspWriter
    ** page = this
    ** config = ServletConfig
    ** all session/app beans declared in globals.jsa
    */
    PageContext pageContext = JspFactory.getDefaultFactory().getPageContext( this, request, response, null, true, JspWriter.DEFAULT_BUFFER, true);
    // Note: this is not emitted if the session directive == false
    HttpSession session = pageContext.getSession();
    int __jsp_tag_starteval;
    ServletContext application = pageContext.getServletContext();
    JspWriter out = pageContext.getOut();
    _rwWarmUp page = this;
    ServletConfig config = pageContext.getServletConfig();

    com.evermind.server.http.JspCommonExtraWriter __ojsp_s_out = (com.evermind.server.http.JspCommonExtraWriter) out;
    try {
      // global beans
      // end global beans


      __ojsp_s_out.write(__oracle_jsp_text[0]);
      __ojsp_s_out.write(__oracle_jsp_text[1]);
      out.print( new java.util.Date() );
      __ojsp_s_out.write(__oracle_jsp_text[2]);


    }
    catch( Throwable e) {
      try {
        if (out != null) out.clear();
      }
      catch( Exception clearException) {
      }
      pageContext.handlePageException( e);
    }
    finally {
      OracleJspRuntime.extraHandlePCFinally(pageContext,false);
      JspFactory.getDefaultFactory().releasePageContext(pageContext);
    }

  }
  private static final byte __oracle_jsp_text[][]=new byte[3][];
  static {
    try {
    __oracle_jsp_text[0] = 
    "<!--\r\n This file is use to warm start the internal web server in the Reports Builder.\r\n It's executed as soon as the webserver is ready to service request.\r\n\r\n It currently contains:\r\n   - The \"session\" page directive is used to start up OC4J's session-id \r\n     seed generator. Once startup, the next session-full JSP request takes\r\n     significantly faster to service. \r\n\r\n NOTE:\r\n   Only put Builder related initializations in this file.\r\n-->\r\n".getBytes("ISO8859_1");
    __oracle_jsp_text[1] = 
    "\r\n<HTML> \r\n  <BODY> \r\n    ".getBytes("ISO8859_1");
    __oracle_jsp_text[2] = 
    "\r\n  </BODY> \r\n</HTML> \r\n".getBytes("ISO8859_1");
    }
    catch (Throwable th) {
      System.err.println(th);
    }
}
}
