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

String pageTitle = "Export Course Lists";
String pageInstructions = "This section allows you to easily download a list of courses from your system and is useful when planning a course archive, to prepare batch files. <br /><br /> <strong>Note:</strong> you do not need to send this data during information gathering, it is only needed during  migration.";

String thisPage = "Export Course Lists";
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
                <bbNG:landingPageSection title="Download Course List" instructions="You can download a CSV for various different course lists.  ">
                    <ul>
                        <li><a href="b2migcsv.jsp?req=courseids-allactive">Course IDs: for all Enabled and Active courses</a></li>
                        <li><a href="b2migcsv.jsp?req=coursedetails-allactive">Course Details: for all Enabled and Active courses</a></li>
                        <li><a href="b2migcsv.jsp?req=coursedetails-allnotactive">Course Details: for all Disabled or Inactive courses</a></li>
                        <li><a href="b2migcsv.jsp?req=coursedetails-all">Course Details: For All Courses</a></li>

                  </ul>
                 </bbNG:landingPageSection>
            </bbNG:landingPageColumn>
        </bbNG:landingPage>
</bbNG:genericPage>
