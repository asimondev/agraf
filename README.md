# agraf
AGRAF export / import scripts.

This *README* describe the usage of AGRAF tool to create performance charts for Oracle Databases. The charts are created by exporting the selected AWR and dynamic views content into the plan CSV and text files. These files must be imported into the MySQL databases. In the next step you use Grafana and AGRAF App to display the imported data.

# How to use AGRAF? #

1. Export data from AWR and dynamic files into CSV and plan text files.
1. Transfer the files to the server with your MySQL server.
1. Import the data into the MySQL server.
1. Use browser to access Grafana server and set up the agraf_mysql database configuration property.

## Exporting the data. ##

* Extract the AGRAF export tar archive into a local directory on the Oracle database server.
* Change directory to the "oracle" subdirectory of the extracted archive.
* Run agraf_export.py script to collect the data. You must have the corresponding privileges to connect to the Oracle database as the internal user. (No prompt for SYS user password.) Do not forget to specify the output directory (-o option).
* The export script will extract all data to the output directory and create the gzipped tar files. You need only these tar files.

## Transfer exported files. ##

AGRAF uses MySQL LOAD DATA INFILE statements to import the data into the MySQL tables at a very high speed. You have to allow the corresponding MySQL user the access to the specific directories for using LOAD DATA. So you have to extract the imported data into the specific directory. Eventually you will have to provide the MySQL user the read permissions to access the extracted files (chown or chmod).

## Importing the data. ##
* Extract the AGRAF import tar archive into a local directory on the MySQL database server.
* Change directory to the "mysql" subdirectory of the extracted archive.
* Run agraf_import.py script to import the data. You must provide the database name, database user, database password and the directory with the exported data.
* The script will re-create all tables and load the data.

## Using performance charts. ##

Before displaying the charts you have to set up once the Grafana server:

* Set up MySQL datatabase.
* Import AGRAF dashboards.

Now you can connect to the Grafana server with your browser and use the performance charts. Some charts need specific details like SQL_ID. You should insert these data manually using INSERT statements into the corresponding AGRAF MySQL tables. Do not forget, that every import will re-create all tables.

## Data export examples. ##

Use -h option to see the help text for agraf_export.py.

Export data between the specified start time and now. No AWR/ADDM reports will be generated.

    agraf_export.py --begin_time "2019-01-14 19:45" --end_time now  -o ~/tmp/output

The usual export does not export segment statistics, because it takes more time and creates larger files. The following command will export data between the specified start time and now with segment statistics.

    agraf_export.py -b "2019-01-14 19:45" -e now  -o ~/tmp/output ---components seg

Export data between the specified start time and now. Additionally the AWR/ADDM reports will be generated as html files.

    agraf_export.py --begin_time "2019-01-14" --end_time now  -o ~/tmp/output -a

Export data between the specified start time and now. Additionally the AWR/ADDM reports will be generated both as html and text files.

    agraf_export.py -b "2019-01-14" -e now  -o ~/tmp/output --report awr,addm --format html,text

Export data between the specified start time and now. The AWR/ADDM reports will be generated as well. These reports will be generated in parallel with max parallel degree of 4. Because of the "--summary" option additionally AWR/ADDM reports for the whole interval will be generated.

    agraf_export.py --begin_time "2019-01-14" --end_time now  -o ~/tmp/output -a --parallel 4 --summary

Generate AWR SQL reports for the specified SQL_IDs. Because of the "--summary_only" option, only one SQL report for the whole AWR interval between min and max snapshot ids will be created.

    agraf_export.py --min_snap_id 310 -max_snap_id 314 -o ~/tmp/output  --report nodata,sql -s 7z63yy1hazt9s,1uk5m5qbzj1vt --summary_only

## Data import examples. ##

Use -h option to see the help text for agraf_import.py.

Import data for non-CDB database into the MySQL database grafana using the specified database account. The location of the extracted CSV files are provided in the "-i" option.

    graf_import.py --database grafana --user grafana --password GrafanaPassword -i /u01/mysql-files

Import data for a CDB database into the MySQL database grafana using the specified database account. The location of the extracted CSV files are provided in the "-i" option.

    graf_import.py -d grafana -u grafana -p GrafanaPassword -i /u01/mysql-files
oracle@avmol7db1> 
