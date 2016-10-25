<%@ page	language="java"
         import="java.util.*,
         java.util.*,
         blackboard.bbmh.*,
         java.text.SimpleDateFormat,
         blackboard.platform.security.SecurityUtil"
         pageEncoding="UTF-8"
         %>

<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<%
// Entitlement check - fail if user it not system admin.  TODO: This is working in that it stops non-admin from viewing the page, but it is generating an error itself
// access denied ("blackboard.data.AttributePermission" "user.authinfo" "get")
blackboard.platform.security.SecurityUtil.checkEntitlement("system.buildingblocks.VIEW","System Admin permissions are required");

   
// Filename
SimpleDateFormat appFormatter = new SimpleDateFormat("yyyy-MM-dd");
java.util.Date dtAppServerTime = new java.util.Date();
String appServerDate = appFormatter.format(dtAppServerTime);
String fullHostname = AppServerInfo.getUrl();
String outputFileName = "b2list-"+fullHostname+"-"+appServerDate+".csv";

// Pull list of B2s
List<B2Helper> b2s = new ArrayList<B2Helper>();
b2s = B2HelperFactory.getB2s();

String b2csv = "\"Name\",\"Version\",\"Vendor Name\",\"Vendor ID\",\"Handle\",\"Status\",\"WAR File Present?\",\"Last Modified\"\n";

int index = 0 ;
while (b2s.size()> index) {
    B2Helper curB2 = b2s.get(index);
    b2csv = b2csv +  "\"" + curB2.localizedName + "\",";
    b2csv = b2csv +  "\"" + curB2.version + "\",";
    b2csv = b2csv +  "\"" + curB2.vendorName + "\",";
    b2csv = b2csv +  "\"" + curB2.vendor_id + "\",";
    b2csv = b2csv +  "\"" + curB2.handle + "\",";
    b2csv = b2csv +  "\"" + curB2.status + "\",";
    b2csv = b2csv +  "\"" + curB2.hasWarFile + "\",";
    b2csv = b2csv +  "\"" + curB2.dateModified + "\"";
    b2csv = b2csv + "\n";

    index++ ;
}



// output as CSV
response.setContentType("text/csv");
response.setHeader("Content-Disposition", "attachment; filename="+outputFileName);
%>
<%=b2csv%>