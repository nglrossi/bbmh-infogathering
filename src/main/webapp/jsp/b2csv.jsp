<%@ page	language="java"
         import="java.util.*,
         java.sql.*,
         java.util.*,
         blackboard.bbmh.*,
         java.text.SimpleDateFormat,
         java.io.File,
         blackboard.platform.plugin.*"
         pageEncoding="UTF-8"
         %>

<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<%
// Filename
SimpleDateFormat appFormatter = new SimpleDateFormat("yyyy-MM-dd");
java.util.Date dtAppServerTime = new java.util.Date();
String appServerDate = appFormatter.format(dtAppServerTime);
String fullHostname = AppServerInfo.getUrl();
String outputFileName = "b2list-"+fullHostname+"-"+appServerDate+".csv";


String b2csv = "\"Name\",\"Version\",\"Vendor Name\",\"Vendor ID\",\"Handle\",\"Status\",\"WAR File Present?\",\"Last Modified\"\n";
PlugInManager pm = PlugInManagerFactory.getInstance();

    // TODO: use B2Helper class instead (need to add getters or possible some other change to do this)
    // TODO: replacr SQL query with public java.util.List<blackboard.platform.plugin.PlugIn> getPlugIns()
    // http://library.blackboard.com/ref/16ce28ed-bbca-4c63-8a85-8427e135a710/blackboard/platform/plugin/PlugInManager.html#getPlugIns--

    Connection dbConnection = Db.getConnection();
    SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");
    String qrystr = "";
    switch (DbServerInfo.getDatabaseType()) {
        case "oracle":
            qrystr = "select name, vendor_id, handle, vendor_name, version_major, version_minor, version_patch, version_build, available_flag, dtmodified " +
"  FROM plugins "  +
"ORDER BY vendor_id,handle";
            break;
        case "mssql":
            qrystr = "select name, vendor_id, handle, vendor_name, version_major, version_minor, version_patch, version_build, available_flag, dtmodified from plugins order by vendor_id,handle";
            break;
        case "pgsql":
            qrystr = "select name, vendor_id, handle, vendor_name, version_major, version_minor, version_patch, version_build, available_flag, dtmodified from plugins order by vendor_id,handle";
            break;
        default:
        // nothing to do
    }
    Statement dbStatement = Db.createStatement(dbConnection);
    ResultSet rs = null;
    try {
        try {
            boolean wasExecuted = dbStatement.execute(qrystr);
            if (wasExecuted) {
                rs = dbStatement.getResultSet();
                while (rs.next()) {
                   String vendor_id = rs.getString("vendor_id");
                   String vendor_name = rs.getString("vendor_name");
                   String handle = rs.getString("handle");
                   String dtmodified= formatter.format(formatter.parse(rs.getString("dtmodified")));

                   // using B2Helper to do localization
                   String name = B2Helper.getLocalisationString(rs.getString("name"), vendor_id, handle);

                    // using code of B2Helper.setVersion directly
                    String version = rs.getInt("version_major") + "." + rs.getInt("version_minor");
                    if ( rs.getInt("version_patch") != -1 ) version += "." + rs.getInt("version_patch");
                    if ( rs.getInt("version_build") != -1 ) version += "." + rs.getInt("version_build");

                   // using code of B2Helper.setAvailableFlag directly
                   String status = "";
                   switch(rs.getString("available_flag")) {
                            case "I":
                                status = "Inactive";
                                break;
                            case "Y":
                                status = "Available";
                                break;
                            case "U":
                               status = "Unavailable";
                                break;
                            case "C":
                                status = "Corrupt";
                                break;
                            default:
                                status = "Unrecognized Status";
                                break;
                        }

                    // check for war file

                    //filepath = blackboard.platform.config.ConfigurationServiceFactory.getInstance().getBbProperty("bbconfig.base.shared.dir");
                    PlugIn pi = new PlugIn();
                    pi = pm.getPlugIn(vendor_id,handle);
                    File pidir = pm.getPlugInDir(pi);
                    // TO DO: windows is backslash
                    File warfile =  new File (pidir.getAbsolutePath() + File.separator + vendor_id+"-"+handle+".war");
                    String war = "TBD";
                    if (warfile.exists()){
                        war="Yes";
                    } else {
                        war="No";
                    }
                    // append to csv
                    b2csv=b2csv + "\"" + name +"\","+ version +",\""+ vendor_name +"\",\""+ vendor_id +"\",\""+ handle +"\",\""+ status +"\",\""+war+"\","+ dtmodified +"\n";

                    //B2Helper b2local = new B2Helper(rs.getString("vendor_id"), rs.getString("handle"));
                    //b2local.setName(rs.getString("name"));
                    //b2local.setLocalizedName(rs.getString("name"));
                    //b2local.setVendorName(rs.getString("vendor_name"));
                    //b2local.setVersion(rs.getInt("version_major"), rs.getInt("version_minor"), rs.getInt("version_patch"), rs.getInt("version_build"));
                    //b2local.setAvailableFlag(rs.getString("available_flag"));
                    //b2local.setDateModified(anotherdbformatter.parse(rs.getString("dtmodified")));
                    //b2s.add(b2local);

                }
            }
        } finally {
            if (rs != null) {
                rs.close();
            }
            if (dbStatement != null) {
                dbStatement.close();
            }
            if(dbConnection != null){
                dbConnection.close();
            }
        }
    } catch (Exception e) {
        // TODO: log in logs
        //dbVersion = "exception " + e + " " ;
    }

// output as CSV
response.setContentType("text/csv");
response.setHeader("Content-Disposition", "attachment; filename="+outputFileName);
%>
<%=b2csv%>