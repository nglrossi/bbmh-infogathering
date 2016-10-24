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

String pageTitle = "B2 Migration Exports";
String pageInstructions =   "Some Building Block vendors (including Blackboard) may request data from the source and target system to assist with re-mapping data following a course-based migration. "
                    +       "This section allows you to easily download common types of export requested. <br /><br /> <strong>Note:</strong> You will typically need to downlod the same exports on both the source and target system.";

String thisPage = "B2 Migration Exports";
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
                <bbNG:landingPageSection title="Generic Exports" instructions="Many B2 vendors may ask for user and course PK1 information for mapping purposes. Where these reports are requested for specific B2s below this is indicated with an asterisk: you only need to download the generic exports once.">
                    <ul>
                        <li><a href="b2migcsv.jsp?req=coursePK1s">Generic Course IDs and PK1 values</a></li>
                        <li><a href="b2migcsv.jsp?req=userPK1s">Generic User IDs and PK1 values</a></li>
                    </ul>
                </bbNG:landingPageSection>
                <bbNG:landingPageSection title="Safeassign" instructions="For Safeassign, you will need to provide the three reports below where requested:">
                    <ul>
                        <li><a href="b2migcsv.jsp?req=safeassignments">SafeAssignment List</a></li>
                        <li><a href="b2migcsv.jsp?req=coursePK1sSafeassign">Safeassign Course IDs and PK1 values</a></li>
                        <li><a href="b2migcsv.jsp?req=userPK1s">Generic User IDs and PK1 values* </a></li>
                    </ul>
                </bbNG:landingPageSection>
                <bbNG:landingPageSection title="Assignments (Crocodoc)" instructions="To migrate inline markup on assignments, you will need to provide the files below when requested:">
                    <ul>
                        <li><a href="b2migcsv.jsp?req=crocodocLicense">Crocodoc License key</a></li>
                        <li><a href="b2migcsv.jsp?req=crocodocAnnotations">Annotated Assignment Attempts</a></li>
                    </ul>
                </bbNG:landingPageSection>
            </bbNG:landingPageColumn>

        </bbNG:landingPage>
</bbNG:genericPage>
