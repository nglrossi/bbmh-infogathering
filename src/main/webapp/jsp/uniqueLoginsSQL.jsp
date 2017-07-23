<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd"> 
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd"> 
<%@ page language="java" 
import="java.net.*,
java.util.*,
java.io.*,
blackboard.platform.config.ConfigurationServiceFactory,
blackboard.platform.config.*,
blackboard.bbmh.*

" pageEncoding="UTF-8" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib prefix="bbNG" uri="/bbNG"%>
<c:set var="dbType" value="unknown"/>

<%

String thisPage = "Unique Logins SQL";
String pageTitle = "Learn Migration Information Gathering - "+thisPage;
String pageInstructions =   "The Unique Logins query is long running and may time out when run through the browser. As an alternative you can run the SQL below directly on your database during an off-peak period. This report lists unique logins on the system during the past few months based on information in the Activity Accumulator." 
   +   "<br /><br />The SQL below counts the last 30 days. Run the query multiple times, changing <strong>30</strong> to 60, 90, 120, 180 in order to provide a broader range of data.";
String cancelUrl = "index.jsp";

// getting db type so we can display correct SQL
pageContext.setAttribute("dbType", DbServerInfo.getDatabaseType());

   
%>




<bbNG:genericPage ctxId="ctx" entitlement="system.buildingblocks.VIEW">
    <bbNG:breadcrumbBar environment="SYS_ADMIN" navItem="admin_main">
        <bbNG:breadcrumb title="Learn Migration Information Gathering" href="<%= cancelUrl %>" />
        <bbNG:breadcrumb><%=thisPage%></bbNG:breadcrumb>
    </bbNG:breadcrumbBar>
    <bbNG:pageHeader instructions="<%=pageInstructions%>">
        <bbNG:pageTitleBar ><%=pageTitle%></bbNG:pageTitleBar>
    </bbNG:pageHeader>    
            
            
        <bbNG:landingPage>
            <bbNG:landingPageColumn>
                <c:if test="${dbType == 'mssql'}">
                    <bbNG:landingPageSection title="SQL Server SQL" instructions="">
<pre>
SELECT count(distinct (user_pk1)) valuen 
from activity_accumulator where event_type = 'LOGIN_ATTEMPT'
and data = 'Login succeeded.' and timestamp >= sysdate-30";
</pre>
                    </bbNG:landingPageSection>
                </c:if> 
                <c:if test="${dbType == 'oracle'}">
                    <bbNG:landingPageSection title="Oracle SQL" instructions="">
<pre>
SELECT count(distinct (user_pk1)) valuen
from activity_accumulator where event_type = 'LOGIN_ATTEMPT' 
and data = 'Login succeeded.' and timestamp >= DATEADD(DAY, -30, GETDATE ());
</pre>
                     </bbNG:landingPageSection>
               </c:if> 
                <c:if test="${dbType == 'pgsql'}">
                    <bbNG:landingPageSection title="Postgres SQL" instructions="">
<pre>
SELECT count(distinct (user_pk1)) valuen
from activity_accumulator where event_type = 'LOGIN_ATTEMPT'
and data = 'Login succeeded.' and timestamp >= current_date - ( 30 * INTERVAL '1' DAY);
</pre>
             </bbNG:landingPageSection>
                </c:if> 
           </bbNG:landingPageColumn>
        </bbNG:landingPage>
</bbNG:genericPage>
