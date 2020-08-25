# AGRAF
AGRAF Python export / import scripts.

This *README* describes the usage of AGRAF Python scripts to export performance data from Oracle database and import them into MySQL database. The export is done into plain CSV and text files. During the export the tool uses SQL*Plus to select the data from AWR and some other views. You can find the list of all used data sources in the file agraf_contents.txt in the export output directory.  

It's recommended to specify **-a** option to export AWR HTML reports 
and ADDM reports. The SQL statements are not exported directly. They will be extracted by parsing AWR HTML reports.   

The import Python script uses MySQL client and LOAD DATA INFILE statements.

# How to use AGRAF export / import scripts? #

1. Export data from AWR and dynamic files into CSV and plan text files.
1. Transfer the files to the server running your MySQL server.
1. Import the data into the MySQL server.

## Exporting the data. ##

* Unpack the AGRAF export tar archive into a new local directory on the Oracle database server.
* Change directory to the "oracle" subdirectory of the extracted archive.
* Create a new output directory.
* Set Oracle environment. The tool uses SQL*Plus internal connect without a password. (The connect "sqlplus / as sysdba" must work!)
* Run agraf_export.py script to export the data and specify the time interval for data export. Do not forget to specify the output directory (-o option).
* Usually you should specify "-a" to option to export AWR and ADDM reports as well. 
* Per default the export does not select segment statistics because of possible large size of CSV files. The option "-c seg" allows you to export them.
* The script will extract all data into the output directory and create the gzipped tar file(s).
* See export examples below for more details.

## Transfer exported files. ##

AGRAF uses MySQL LOAD DATA INFILE statements to import the data into the MySQL tables at a very high speed from the specific directory. The MySQL parameter **secure_file_priv** must set this directory in the MySQL parameter file. Additionally you have to give the corresponding MySQL database user the access to this specific "import" directory.

That's why you have to extract the imported data into the specific "import" directory. Eventually you will have to provide the MySQL user the read permissions to access the extracted files (chown / chmod).

## Importing the data. ##

* Extract the AGRAF import scripts tar archive into the new directory on the MySQL database server.
* Change directory to the "mysql" subdirectory of the extracted archive.
* Run agraf_import.py script to import the data. You must provide the database name, database user, database password and the import directory with the exported data in of plan CSV and text files. These parameters 
can also by specifed as AGRAF_XXX environment variables or in a 
JSON configuration file.
* The script will re-create all interal tables and load the data.
* See import examples below for more details.

## Data export examples. ##

Use -h option to see the help text for agraf_export.py.

Export data between for the specified time interval. The AWR/ADDM reports will be generated as well ("-a" option). The export will be done to the specified output directory ("-o" option).

    agraf_export.py --begin_time "2019-01-14 08:45" --end_time "2019-01-14 08:45" -a  -o ../output

The usual export does not export segment statistics, because it takes more time and creates larger files. The following command will export data, segment statistics and AWR/ADDM reports.

    agraf_export.py -b "2019-01-14" -e now -a -o ~/tmp/output ---components seg

Export data between the specified start time and now. Additionally the AWR/ADDM reports will be generated both as html and text files.

    agraf_export.py -b "2019-01-14" -e now  -o ~/tmp/output --report awr,addm --format html,text

Export data between the specified start time and now. The AWR/ADDM reports will be generated as well. These reports will be generated in parallel with max parallel degree of 4. Because of the "--summary" option additionally AWR/ADDM reports for the whole interval will be generated.

    agraf_export.py --begin_time "2019-01-14" --end_time now  -o ~/tmp/output -a --parallel 4 --summary

Generate AWR SQL reports for the specified SQL_IDs. Because of the "--summary_only" option, only one SQL report for the whole AWR interval between min and max snapshot ids will be created.

    agraf_export.py --min_snap_id 310 -max_snap_id 314 -o ~/tmp/output  --report nodata,sql -s 7z63yy1hazt9s,1uk5m5qbzj1vt --summary_only

## Data import examples. ##

Use -h option to see the help text for agraf_import.py.

Import data for into the MySQL database grafana using the specified database account. The location of the extracted CSV files (import directory) is provided by the "-i" option.

    agraf_import.py --database grafana --user grafana --password UserPassword -i /agraf/import

Usually you would run the agraf_import.py with the same parametrs. So 
you could create the file env.json with all parameters:

    {  
        "database": "grafana",  
        "user": "grafana",  
        "password": "UserPassword",  
        "import_dir": "/agraf/import"  
    }  

You can run import now using the configuration file option:

    agraf_import.py -c env.json  

You could also set the environment variables AGRAF_MYSQL_DATABASE,
AGRAF_MYSQL_USER, AGRAF_MYSQL_PASSWORD, AGRAF_IMPORT_DIR and run 
import without any parameters.

It is also possible to specify some parameters on the command line and  use JSON configuration file and / or environment variables for others.

