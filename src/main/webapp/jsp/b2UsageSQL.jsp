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

String thisPage = "Building Block Usage SQL";
String pageTitle = "Learn Migration Information Gathering - "+thisPage;
String pageInstructions =   "The Building Block Usage query is long running and may time out when run through the browser. As an alternative you can run the SQL below directly on your database during an off-peak period. The output lists all installed Building Blocks. It includes an extra column to indicate usage based on the number of hits recorded in Activity Accumulator in the last year.";
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
SELECT Name, Vendor_Name,
Vendor_ID + '-' + Handle Handle, cast (Version_Major as varchar) + '.' + cast(Version_Minor as varchar)+ '.' + cast(Version_Patch as varchar) Version, Available_Flag,
coalesce(mycount,0) Hits_Last_Year
from plugins left outer join
(select count(1) mycount, substring(data,1,charindex('-',substring(data,1,charindex('/',data,10)),-1) ) mydata
from activity_accumulator
where timestamp >= getdate() -365
and data like '/webapps/%-%/%'
group by substring(data,1,charindex('-',substring(data,1,charindex('/',data,10)),-1) )) aa
on aa.mydata= '/webapps/'+ Vendor_ID + '-' + Handle
ORDER BY Hits_Last_Year desc;
</pre>
                    </bbNG:landingPageSection>
                </c:if> 
                <c:if test="${dbType == 'oracle'}">
                    <bbNG:landingPageSection title="Oracle SQL" instructions="">
<pre>
select name, vendor_id, handle, vendor_name, available_flag, dtmodified, NVL(mycount,0) hits_last_year
FROM plugins LEFT OUTER JOIN (SELECT COUNT(1) mycount, SUBSTR(data,1,instr(SUBSTR(data,1,instr(data,'/',10,1)),'-',-1,1) -1 ) mydata
FROM activity_accumulator WHERE TIMESTAMP >= sysdate -365 " AND data LIKE '/webapps/%-%/%' "
GROUP BY SUBSTR(data,1,instr(SUBSTR(data,1,instr(data,'/',10,1)),'-',-1,1) -1 ) " ) aa
ON aa.mydata= '/webapps/' || Vendor_ID  || '-'  || Handle "
ORDER BY hits_last_year desc";
</pre>
                     </bbNG:landingPageSection>
               </c:if> 
                <c:if test="${dbType == 'pgsql'}">
                    <bbNG:landingPageSection title="Postgres SQL" instructions="">
<strong>1. Create Function</strong><br />
<pre>
create or replace function bbmhgatheringinstr(str text, sub text, startpos int = 1, occurrence int = 1)
returns int language plpgsql
as $$
declare
tail text;
shift int;
pos int;
i int; 
begin
shift:= 0;
if startpos = 0 or occurrence <= 0 then
    return 0; 
end if;
if startpos < 0 then
    str:= reverse(str);
    sub:= reverse(sub);
    pos:= -startpos; 
else 
    pos:= startpos; 
end if; 
for i in 1..occurrence loop 
    shift:= shift+ pos; 
    tail:= substr(str, shift); 
    pos:= strpos(tail, sub); 
    if pos = 0 then 
        return 0; 
        end if; 
end loop; 
if startpos > 0 then 
    return pos+ shift- 1; 
else 
    return length(str)- pos- shift+ 1; 
end if; 
end $$;
</pre> <br />
<strong>2. Run Query</strong>
<pre>                    
SELECT name, vendor_id, handle, vendor_name, available_flag, dtmodified
coalesce(mycount,0) Hits_Last_Year 
from plugins left outer join 
(select count(1) mycount, substr(data,1,bbmhgatheringinstr(substr(data,1,bbmhgatheringinstr(data,'/',10,1)),'-',-1,1) -1 ) mydata 
from activity_accumulator 
where timestamp >= clock_timestamp()::timestamp - interval '365 days' 
and data like '/webapps/%-%/%' 
group by substr(data,1,bbmhgatheringinstr(substr(data,1,bbmhgatheringinstr(data,'/',10,1)),'-',-1,1) -1 )) aa 
on aa.mydata= '/webapps/'|| vendor_id || '-' || handle 
ORDER BY Name";
</pre>
             </bbNG:landingPageSection>
                </c:if> 
           </bbNG:landingPageColumn>
        </bbNG:landingPage>
</bbNG:genericPage>
