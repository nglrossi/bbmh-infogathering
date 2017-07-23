<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd"> 
<%@ page language="java" 
import="java.net.*,
java.util.*,
java.io.*,
blackboard.platform.config.ConfigurationServiceFactory,
blackboard.platform.config.*
" pageEncoding="UTF-8" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib prefix="bbNG" uri="/bbNG"%>
<c:set var="dbType" value="unknown"/>

<%

String pageTitle = "Learn Migration Information Gathering";
String pageInstructions = "This tool will gather statistical data about your Blackboard Learn environment for use by you and Blackboard as a baseline for scoping and planning a potential move to Blackboard Managed Hosting or SaaS. There are also other reports and data extracts that may be requested during your migration.<br /><br />\n"
                        + "Additional information about this tool, and the supporting files, can be found in <a target=\"_blank\" href=\"https://help.blackboard.com/Learn/Administrator/Hosting/Migration_Planning/Information_Gathering_for_Blackboard_Learn_Migration\">Blackboard Help</a>.<br /><br />";

String thisPage = "Settings";
String cancelUrl = "index.jsp";

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
                <bbNG:landingPageSection title="Settings" instructions="There are no settings for this Building Block">
                </bbNG:landingPageSection>
               <bbNG:landingPageSection title="<a href=\"index.jsp\">Access Migration Information Gathering Reports</a>" instructions="You can access the reports via the Tools list in System Admin, or via the above link.">
             </bbNG:landingPageSection>
            </bbNG:landingPageColumn>

        </bbNG:landingPage>
</bbNG:genericPage>
