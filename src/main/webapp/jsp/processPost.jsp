<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd"> 
<%@ page	language="java" 
         import="java.util.*,
         java.util.*,
         java.sql.*,
         blackboard.platform.LicenseUtil,
         blackboard.platform.config.BbConfig,
         blackboard.platform.config.ConfigurationServiceFactory,
         blackboard.data.*,
         blackboard.db.*,
         blackboard.platform.*,
         blackboard.platform.db.*,
         blackboard.base.*,
         blackboard.data.*,
         blackboard.data.user.*,
         blackboard.data.course.*,
         blackboard.persist.*,
         blackboard.persist.user.*,
         blackboard.persist.course.*,
         blackboard.platform.*,
         blackboard.platform.session.*,
         blackboard.platform.tracking.TrackingEventManager,
         blackboard.platform.tracking.data.TrackingEvent,
         org.apache.commons.lang.StringEscapeUtils,
         blackboard.platform.security.SecurityUtil
         "           
         pageEncoding="UTF-8" 
         %>

<%@ taglib uri="/bbData" prefix="bbData"%>
<%@ taglib uri="/bbNG" prefix="bbNG"%>
<%
String pageTitle = "Bb Managed Hosting Info gathering";
String cancelUrl = "index.jsp";
//String submitUrl = "processPost.jsp";
String pageInstructions = "Bbmh tool for gathering information as part of the onboarding to managed hosting.\n"
+ "<br/>Report completed";
String content = "";
%>

<%
// Detect OS
// TODO: move code as a method in a JAR
String osFlavour = "";
if(blackboard.util.PlatformUtil.osIsWindows()){
    osFlavour = "Windows not yet supported";
}else{
    osFlavour = "UNIX system";
}   
%>

<%
// Detect Learn Version
// TODO: move code as a method in a JAR
String learnVersion = "";

learnVersion = blackboard.platform.LicenseUtil.getBuildNumber();
%>

<%
// Detect whether MSSQL/Oracle/Postgres 
// TODO: move code as a method in a JAR
String dbType = "";
String dbVersion = "";
dbType = ConfigurationServiceFactory.getInstance().getBbProperty( blackboard.platform.config.BbConfig.DATABASE_TYPE );
String qrystr = "";

// Detect db server version
switch(dbType) {
    case "oracle":
        dbVersion = "hardcoded Oracle 7a, need to implement the right query";
        // SELECT version();
        break;
    case "mssqlserver":
        // TODO detect MSSQL version and put the right case label
        dbVersion = "hardcoded MSSQL 1234, need to implement the right query";
        break;
    case "pgsql":   
        // TODO detect ORACLE version and put the right case label
        qrystr = "select version()";
        break;
    default:
        dbVersion = "unable to detect db version";
    
}


ConnectionManager conman  = null;
Connection conn = null;
Statement stmt = null;
ResultSet rs = null;
//String strResults = "No Current Resulset";

//String url = "";
//String handler = "";

try {
        // Create Conn to correct database
            int j=0;

            BbDatabase bbDb = DbUtil.safeGetBbDatabase();
            conman = bbDb.getConnectionManager();
            while(conn == null && j<10){
               try {
                      conn = conman.getConnection();
                  }
                  catch(ConnectionNotAvailableException cnae){
                      Thread.sleep(1000);
                      ++j;
           }
            }

        stmt = conn.createStatement();
					
	 
        //out.println("Query : " + qrystr + "<br/>");
	
        
        boolean wasExecuted = stmt.execute(qrystr);
        BbSession userSession = BbSessionManagerServiceFactory.getInstance().getSession(request);
        TrackingEventManager trackingMgr = (TrackingEventManager) BbServiceManager.lookupService(TrackingEventManager.class);
        if (trackingMgr != null) {
               TrackingEvent recordedEvent = new TrackingEvent();
               recordedEvent.setInternalHandle("bbsupport_tool_dbpool");
               recordedEvent.setType(TrackingEvent.Type.PAGE_ACCESS);
               recordedEvent.setData("Query: " + qrystr + " Executed");
               recordedEvent.setSessionId(userSession.getBbSessionId());
               recordedEvent.setUserId(userSession.getUserId());
               trackingMgr.postTrackingEvent(recordedEvent);
        } 
                if (wasExecuted) {
                        rs = stmt.getResultSet();
                        ResultSetMetaData rsMetaData = rs.getMetaData();
                        //int numberOfColumns = rsMetaData.getColumnCount();

                        while(rs.next()) {
                            dbVersion = StringEscapeUtils.escapeHtml(rs.getString(1));
                                }
                        
                }else{
                        int updateCount = stmt.getUpdateCount();
                        // Success.
                        out.println("Statement Executed (" + updateCount + ") rows afected<br/>");
                }
        

}catch(Exception e) {
        out.println("query failed<br/>");
        out.println(e);
}finally{
        if(rs != null){
                rs.close();
                }
        if(stmt != null){
                stmt.close();
                }
    if(conman != null){
             conman.releaseConnection(conn);
                }
        }





%>

<bbNG:genericPage ctxId="ctx" entitlement="system.plugin.CREATE">
    <bbNG:breadcrumbBar environment="SYS_ADMIN" navItem="admin_main">
        <bbNG:breadcrumb title="BB Support Tools" href="<%= cancelUrl %>" />
        <bbNG:breadcrumb><%=pageTitle%></bbNG:breadcrumb>
    </bbNG:breadcrumbBar>
    <bbNG:pageHeader instructions="<%=pageInstructions%>">
        <bbNG:pageTitleBar ><%=pageTitle%></bbNG:pageTitleBar>
    </bbNG:pageHeader>

    <bbNG:dataCollection>

        <bbNG:step title="Operating System">
            <bbNG:dataElement label="OS" isRequired="yes" labelFor="OS">
                <%=osFlavour%>
            </bbNG:dataElement>
        </bbNG:step>

        <bbNG:step title="Learn Version">
            <bbNG:dataElement label="Learn Version" isRequired="yes" labelFor="LV">
                <%=learnVersion%>
            </bbNG:dataElement>
        </bbNG:step>

        <bbNG:step title="Database server backend">
            <bbNG:dataElement label="Database server type" isRequired="yes" labelFor="dbtype">
                <%=dbType%>
            </bbNG:dataElement>
            <bbNG:dataElement label="Database server version" isRequired="yes" labelFor="dbversion">
                <%=dbVersion%>
            </bbNG:dataElement>
        </bbNG:step>

        <bbNG:stepSubmit cancelUrl="<%=cancelUrl%>" />

    </bbNG:dataCollection>
    <%=content%>
</bbNG:genericPage>

<%
   //String returnUrl="index.jsp";
   //response.sendRedirect(returnUrl);
%>
<%!
//code methods in here e.g. private static boolean pingUrl (String address) {....}
%>