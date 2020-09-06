#!/usr/bin/python
#
# Author: Andrej Simon, Oracle ACS Germany
#
# This is the main script to start import of AWR statistics from
# CSV files into MySQL database. There is one CSV file for each
# DBA_HIST_xxx table.
#
#
# Example: agraf_import.py -d DbName -u User -p Password -i /u01/mysql-files
#

from __future__ import print_function

from time import strftime

import json
import optparse
import os
import re
import sys
import tempfile

AGRAF_VERSION = "1.6.0"

#######################################################################
verbose_flag = False


def set_verbose(flag):
    global verbose_flag
    verbose_flag = flag


def verbose():
    return verbose_flag


#######################################################################
class MySql:
    def __init__(self, stmts=None, sql_file=None,
                 log_file=None):
        self.stmts = stmts
        self.sql_file = sql_file
        self.sql_file_prefix = "agraf_mysql_%s" % os.getpid()
        self.log_file = log_file

    def __str__(self):
        ret = "Class MySql:\n"
        if self.stmts:
            ret += "- stmts: %s\n" % self.stmts
        if self.sql_file:
            ret += "- sql_file: %s\n" % self.sql_file
        if self.sql_file_prefix:
            ret += "- sql_file_prefix: %s\n" % self.sql_file_prefix
        if self.log_file:
            ret += "- log_file: %s\n" % self.log_file

        return ret

    def create_sql_file(self):
        fd, self.sql_file = tempfile.mkstemp('.sql', self.sql_file_prefix)

        os.write(fd, self.stmts + "\n" + "exit\n")
        os.close(fd)

    def exit_on_error(self, out):
        print("SQL script for mysql>>>")
        for line in open(self.sql_file):
            print(line, end='')

        print("\n\nmysql output>>>")
        for line in out:
            print(line, end='')

        sys.exit(1)

    def run(self, conn, do_exit=True):
        remove_file = self.sql_file is None
        if self.sql_file is None:
            self.create_sql_file()

        if verbose():
            print("SQL script for mysql>>>")
            for line in open(self.sql_file):
                print(line, end='')

        cmd = ('mysql -u %s -p%s %s < %s 2>&1' %
               (conn['user'], conn['password'],
                conn['database'], self.sql_file))
        out = []
        try:
            fp = os.popen(cmd)
            out = fp.readlines()
            rc = fp.close()

            if rc and do_exit:
                print("Error: mysql returns with error code %d." % rc)
                self.exit_on_error(out)

        except Exception as e:
            if do_exit:
                print('Error: Unexpected error during running mysql: ', e)
                print(e)
                self.exit_on_error(out)

        finally:
            if remove_file:
                os.remove(self.sql_file)

        if verbose():
            print("mysql output>>>")
            for line in out:
                print(line, end='')

        return [x.strip() for x in out]


#######################################################################
NON_CDB_TABLES = [
    'agraf_components',
    'dba_users',
    'hist_ash_samples',
    'hist_ash_sessions',
    'hist_cr_block_server',
    'hist_current_block_server',
    'hist_database_instance',
    'hist_dyn_remaster_stats',
    'hist_exa_sysstat',
    'hist_filestat',
    'hist_ic_client_stats',
    'hist_inst_cache_transfer',
    'hist_interconnect_pings',
    'hist_iostat_function',
    'hist_osstat',
    'hist_parameter',
    'hist_pgastat',
    'hist_seg_stat',
    'hist_seg_stat_obj',
    'hist_snapshot',
    'hist_sqlstat',
    'hist_sys_time_model',
    'hist_sysstat',
    'hist_sqltext',
    'hist_system_event',
    'hist_thread',
    'hist_tempstat',
    'hist_sysmetric_summary',
    'hist_undostat',
    'vspparameter',
    'vlog', 'vstandby_log', 'vlogfile',
    'hist_instance_recovery',
    'hist_process_mem_summary',
    'hist_log',
]

CDB_ONLY_TABLES = [
    'hist_con_sysstat',
    'hist_con_system_event',
    'hist_con_sys_time_model',
    'hist_exa_con_sysstat',
    'hist_pdb_in_snap',
    'hist_pdb_instance',
    'pdb_spfile',
    'vpdbs',
]


class Database:
    def __init__(self, conn, import_dir, cdb=None):
        self.conn = conn
        self.import_dir = import_dir
        self.cdb = True if cdb else False

        self.awr_tables = NON_CDB_TABLES
        self.cdb_awr_tables = NON_CDB_TABLES + CDB_ONLY_TABLES
        self.mysql_tables = self.cdb_awr_tables if self.cdb else self.awr_tables
        self.load_table_exceptions = self.set_load_table_exceptions()

    def set_load_table_exceptions(self):
        load_tables = dict()
        load_tables['hist_seg_stat_obj'] = """  (ts_id, obj_id, dataobj_id,
            owner, object_name, subobject_name,
            object_type, tablespace_name, partition_type,
            dummy1, con_dbid, con_id, dummy2)
        """
        load_tables['hist_ash_sessions'] = """ (instance_number,
  sample_time, sid, serial, session_state, dummy1,
  event, sql_id, sql_opname, user_id, program, machine,
  client_id, module, is_px,
  pga_allocated, temp_space_allocated,
  blocking_status, blocking_inst_id, blocking_sid, blocking_serial,
  action, con_dbid,
  con_id)
  """
        load_tables['dba_users'] = """  (user_id, username,
            dummy1, con_id, dummy2)
        """
        return load_tables

    def add_load_table(self, table):
        stmts = """truncate table %s
\\g
load data infile
  '%s/%s.csv'
  into table %s
  fields terminated by ';'
  optionally enclosed by '"'
  lines terminated by '\\n'
""" % (table, self.import_dir, table, table)

        if table in self.load_table_exceptions:
            stmts += self.load_table_exceptions[table]

        return stmts + "\\g\n"

    def import_data(self):
        stmts = "select 'Importing CSV files into tables.' as '';\n\n"
        for tab in self.mysql_tables:
            if verbose():
                stmts += "select 'Loading %s ...' as '';\n" % tab
                stmts += "select curtime();\n"
            stmts += "source ./ddl/create_%s.sql\n" % tab
            stmts += self.add_load_table(tab)
            update_script = "./update_%s.sql" % tab
            if os.path.isfile(update_script):
                stmts += "source %s\n\n" % update_script

        cdb_str = "CDB" if self.cdb else "non-CDB"
        print("Starting %s import from CSV files (%s)." %
              (cdb_str, strftime("%H:%M:%S")))
        mysql = MySql(stmts)
        mysql.run(self.conn)

    def prepare_reports(self):
        print("Running post-processing and creating temporary tables (%s)." %
              strftime("%H:%M:%S"))
        if self.cdb:
            sql_file = "prepare_graf_cdb.sql"
        else:
            sql_file = "prepare_graf.sql"
        mysql = MySql(sql_file=sql_file)
        mysql.run(self.conn)

        print("Import finished sucessfully (%s)." %
              strftime("%H:%M:%S"))


#######################################################################
class ProgArgs:
    def __init__(self, config=None,
                 database=None, import_dir=None,
                 user=None, password=None,
                 is_verbose=None):
        self.config = config
        self.database = database
        self.import_dir = import_dir
        self.user = user
        self.password = password
        self.cdb = None

        self.verbose = is_verbose
        set_verbose(False if is_verbose is None else is_verbose)
        if self.config is not None:
            try:
                self.read_json()
            except Exception as e:
                print("Error: can't read JSON config file '%s'" % self.config)
                print(e.args)
                sys.exit(1)

    def __str__(self):
        ret = "Class ProgArgs:\n"
        if self.config:
            ret += "- config: %s\n" % self.config
        if self.user:
            ret += "- user: %s\n" % self.user
        if self.password:
            ret += "- password: %s\n" % self.password
        if self.database:
            ret += "- database: %s\n" % self.database
        if self.import_dir:
            ret += "- import_dir: %s\n" % self.import_dir
        if self.verbose:
            ret += "- verbose: %s\n" % self.verbose
        if self.cdb:
            ret = "- cdb: %s\n" % self.cdb

        return ret

    def read_json(self):
        data = json.load(open(self.config))

        if (self.database is None and 'database' in data and
                data['database'] is not None):
            self.database = data['database']

        if (self.user is None and 'user' in data and
                data['user'] is not None):
            self.user = data['user']

        if (self.password is None and 'password' in data and
                data['password'] is not None):
            self.password = data['password']

        if (self.import_dir is None and 'import_dir' in data and
                data['import_dir'] is not None):
            self.import_dir = data['import_dir']

    def check_import_directory(self):
        if self.import_dir is None:
            if os.getenv("AGRAF_IMPORT_DIR") is not None:
                self.import_dir = os.getenv("AGRAF_IMPORT_DIR")
            else:
                print("Error: mandatory parameter import directory not found.")
                usage()
                sys.exit(1)

        if not os.path.isdir(self.import_dir):
            print("Error: wrong import directory '%s'" % self.import_dir)
            usage()
            sys.exit(1)

        self.import_dir = os.path.normpath(self.import_dir)

    def check_database(self):
        valid = True

        if self.database is None:
            if os.getenv("AGRAF_MYSQL_DATABASE") is not None:
                self.database = os.getenv("AGRAF_MYSQL_DATABASE")
            else:
                print("Error: mandatory parameter database not found.")
                valid = False

        elif self.user is None:
            if os.getenv("AGRAF_MYSQL_USER") is not None:
                self.user = os.getenv("AGRAF_MYSQL_USER")
            else:
                print("Error: mandatory parameter database user not found.")
                valid = False

        elif self.password is None:
            if os.getenv("AGRAF_MYSQL_PASSWORD") is not None:
                self.password = os.getenv("AGRAF_MYSQL_PASSWORD")
            else:
                print("Error: mandatory parameter database password not found.")
                valid = False

        if not valid:
            usage()
            sys.exit(1)

    def check_cdb(self):
        file_name = os.path.join(self.import_dir, 'agraf_components.csv')
        if os.path.exists(file_name):
            pattern = re.compile(r'\Acdb;([\w]+)\s')

            with open(file_name) as my_file:
                for line in my_file:
                    m = pattern.search(line)
                    if m:
                        if m.group(1) == 'yes':
                            return True
                        elif m.group(1) == 'no':
                            return False
                        else:
                            print("Error: unknown CDB component value '%s' "
                                  "in the file %s." % (m.group(1), file_name))
                            sys.exit(1)

            if self.cdb is None:
                print("Error: CDB component not found in "
                      "the file %s." % file_name)
        else:
            print("Error: CDB component not found in "
                  "the file %s." % file_name)

        sys.exit(1)

    def check_args(self):
        self.check_database()
        self.check_import_directory()
        self.cdb = self.check_cdb()

    def get_connect(self):
        return {'database': self.database, 'user': self.user,
                'password': self.password}

    def get_import_dir(self):
        return self.import_dir

    def is_cdb(self):
        return self.cdb


#######################################################################
def parse_args():
    parser = optparse.OptionParser(version="%prog " + AGRAF_VERSION)
    parser.add_option("-c", "--config", help="JSON config file")
    parser.add_option("-d", "--database", help="MySQL database")
    parser.add_option("-i", "--import_dir", help="Import direcotry")
    parser.add_option("-p", "--password", help="MySQL user password")
    parser.add_option("-u", "--user", help="MySQL user")
    parser.add_option("-v", "--verbose", help="verbose",
                      action="store_true", dest="verbose", default=False)

    (options, args) = parser.parse_args()
    prog_args = ProgArgs(
        config=options.config,
        database=options.database,
        user=options.user,
        password=options.password,
        import_dir=options.import_dir,
        is_verbose=options.verbose)
    prog_args.check_args()

    return prog_args


#######################################################################
def usage():
    print("\nParameters: -c JSON_Config_File -d Database -u User -p Password "
          "-i Import_Dir [-v --version]")


#######################################################################
def main():
    args = parse_args()
    if verbose():
        print(args)

    db = Database(args.get_connect(), args.import_dir, args.is_cdb())
    db.import_data()
    db.prepare_reports()


#######################################################################
if __name__ == '__main__':
    main()
