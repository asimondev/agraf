# AGRAF
AGRAF Python export scripts.

This *README* describes the usage of AGRAF Python scripts to export performance data from Oracle database. The export is done into plain CSV and text files. During the export the tool uses SQL*Plus to select the data from AWR and some other views. You can find the list of all used data sources in the file agraf_contents.txt in the export output directory.  

You should specify **-a** option to export AWR HTML reports,  ADDM reports and SQL statements from AWR. This is the recommended approach.

# Exporting the data. ##

* Unpack the AGRAF export tar archive into a new local directory on the Oracle database server.
* Change directory to the "oracle" subdirectory of the extracted archive.
* Create a new output directory: `mkdir ../output`
* Set Oracle environment. The tool uses SQL*Plus internal connect without a password. (The connect "sqlplus / as sysdba" must work!)
* Run agraf_export.py or agraf_export3.py script to export the data and specify the time interval for data export. Use agraf_export.py with Python 2
(Oracle Linux 7) and agraf_export33.py with Python 3 (Oracle Linux 8). 
* Do not forget to specify the output directory (*\-o* option).
* Usually you should specify *\-a* to option to export AWR and ADDM reports as well. 
* If the output directory is not empty, you should clear it or specify the *--cleanup* option.
* Per default the export does not select segment statistics because of possible large size of CSV files. The option *\-c seg* allows you to export them.
* The script will extract all data into the output directory and create the gzipped tar file(s). You only need the gzipped file.
* See export examples below for more details.

## Data export examples. ##

Use *\-h* option to see the help text for agraf_export.py.

Export data for the specified time interval. The AWR/ADDM reports and a file with SQL statements from AWR will be generated as well (*\-a* option). The export will be done to the specified output directory (*\-o* option).

    ./agraf_export.py --begin_time "2019-01-14 23:00" --end_time "2019-01-16 01:00" -a  -o ../output

Use the same options but their short form. Clear all old existing files from the *-output* directory before export:  

    ./agraf_export.py -b "2019-01-14 23:00" -e "2019-01-16 01:00" -a  -o ../output --cleanup

Use the same options but add the parallel export option for AWR and ADDM reports:  

    ./agraf_export.py -b "2019-01-14 23:00" -e "2019-01-16 01:00" -a  -o ../output --cleanup --parallel 4

If you are on Oracle Linux 8, then the server usually does not have Python 2
installed. So you have to use *agraf_python3.py* with Python 3 support for AGRAF export:

    ./agraf_export3.py -b "2019-01-14 23:00" -e "2019-01-16 01:00" -a  -o ../output --cleanup --parallel 4

The usual AGRAF export does not export segment statistics, because it takes more time and creates larger files. The following command will export data, segment statistics and AWR/ADDM reports.

    ./agraf_export.py -b "2019-01-14" -e now -a -o ~/tmp/output ---components seg

Export data between the specified start time and now. Additionally the AWR/ADDM reports will be generated both as html and text files.

    ./agraf_export.py -b "2019-01-14" -e now  -o ~/tmp/output --report awr,addm --format html,text -a

Export data between the specified start time and now. The AWR/ADDM reports will be generated as well. These reports will be generated in parallel with max parallel degree of 4. Because of the *--summary* option additionally AWR/ADDM reports for the whole interval will be generated.

    ./agraf_export.py --begin_time "2019-01-14" --end_time now  -o ~/tmp/output -a --parallel 4 --summary

Generate AWR SQL reports for the specified SQL_IDs. Because of the *--summary_only* option, only one SQL report for the whole AWR interval between min and max snapshot ids will be created.

    ./agraf_export.py --min_snap_id 310 -max_snap_id 314 -o ~/tmp/output  --report nodata,sql -s 7z63yy1hazt9s,1uk5m5qbzj1vt --summary_only

