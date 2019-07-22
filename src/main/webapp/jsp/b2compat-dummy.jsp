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

 
List<String> b2compatdefault = Arrays.asList("Unknown","Unknown","Check with vendor");
Map<String,List<String>> b2compat = new HashMap<String,List<String>>();
String compatdate="B2 Compatibility dummy data.";

b2compat.put("bbmh-info-gathering",Arrays.asList("Yes","--","--",Not applicable for SaaS"));

%>