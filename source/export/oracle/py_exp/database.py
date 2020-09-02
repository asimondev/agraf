#!/usr/bin/python
#
# Author: Andrej Simon, Oracle ACS Germany
#
# This Python module contains Database class, which exports AWR data from
# Oracle database.

from __future__ import print_function

import os
import re
import shutil
import sys
import tempfile

from export_utils import create_tar_file_name
from addm_reports import AddmReports
from awr_reports import AwrReports
from awrsql_reports import AwrSqlReports


class Database:
    def __init__(self, out_dir=None, begin_time=None, end_time=None,
                 begin_snap_id=None, end_snap_id=None, interval_ids=None,
                 db_id=None, inst_id=None, is_rac=None, inst_name=None,
                 is_verbose=False):
        self.begin_time = begin_time
        self.end_time = end_time
        self.begin_snap_id = begin_snap_id
        self.end_snap_id = end_snap_id
        self.interval_ids = interval_ids
        self.is_verbose = is_verbose

        self.out_dir = out_dir
        self.db_id = db_id
        self.inst_id = inst_id
        self.inst_name = inst_name
        self.is_rac = is_rac
        self.version = None
        self.major_version = None
        self.min_snap_id = None
        self.max_snap_id = None
        self.cdb = False
        self.cdb_prefix = None
        # self.in_instance_ids = None
        self.in_inst_ids = None
        self.cell_count = 0
        self.components_file_name = "%s/agraf_components.csv" % self.out_dir
        self.content_file_name = "%s/agraf_contexts.txt" % self.out_dir

    def __str__(self):
        ret = "Class Database:\n"
        if self.interval_ids is not None:
            ret += "- interval_ids: %s\n" % self.interval_ids
        if self.begin_time:
            ret += "- begin_time: %s\n" % self.begin_time
        if self.end_time:
            ret += "- end_time: %s\n" % self.end_time
        if self.begin_snap_id:
            ret += "- begin_snap_id: %s\n" % self.begin_snap_id
        if self.end_snap_id:
            ret += "- end_snap_id: %s\n" % self.end_snap_id

        if self.version:
            ret += "- version: %s\n" % self.version
        if self.major_version:
            ret += "- major_varsion: %s\n" % self.major_version
        if self.db_id:
            ret += "- db_id: %s\n" % self.db_id
        if self.inst_id:
            ret += "- inst_id: %s\n" % self.inst_id
        if self.inst_name:
            ret += "- inst_name: %s\n" % self.inst_name
        if self.is_rac is not None:
            ret += "- is_rac: %s\n" % self.is_rac
        ret += "- cell_count: %d\n" % self.cell_count

        if self.out_dir:
            ret += "- out_dir: %s\n" % self.out_dir
        if self.min_snap_id:
            ret += "- min_snap_id: %s\n" % self.min_snap_id
        if self.max_snap_id:
            ret += "- max_snap_id: %s\n" % self.max_snap_id

        if self.content_file_name:
            ret += "- content_file_name: %s\n" % self.content_file_name

        return ret

    def verbose(self):
        return self.is_verbose

    def interval_string(self):
        ret = "B%s_E%s" % (self.begin_time, self.end_time)
        return ret.replace(' ', '_').replace(':', '-')

    def set_version(self, version, out):
        if version[:2] == "11":
            self.version = "11g"
            self.major_version = 11
        elif version[:4] == "12.1":
            self.version = "12_1"
            self.major_version = 12
        elif version[:4] == "12.2":
            self.version = "12_2"
            self.major_version = 12
        elif version[:2] == "18":
            self.version = "18c"
            self.major_version = 18
        elif version[:2] == "19":
            self.version = "19c"
            self.major_version = 19
        else:
            print("Error: unknown Oracle release '%s' "
                  "found in SQL*Plus output." % version)
            print(out)
            sys.exit(1)

    def get_version(self):
        return self.version

    def check_version(self, out):
        for line in out:
            matchobj = re.match(r'\ASQL\*Plus.*Release[\s]+([\d]+\.[\d]+).*\Z', line)
            if matchobj:
                self.set_version(matchobj.group(1), out)
                return
        else:
            print("Error: can not find the Oracle release in SQL*Plus output>>>")
            print(out)
            sys.exit(1)

    def check_db_id(self, out):
        for line in out:
            matchobj = re.match(r'\ADB_ID:([\d]+):\Z', line)
            if matchobj:
                self.db_id = matchobj.group(1)
                return
        else:
            print("Error: can not find the database ID in SQL*Plus output>>>")
            print(out)
            sys.exit(1)

    def check_inst_id(self, out):
        for line in out:
            matchobj = re.match(r'\AINST_ID:([\d]+):\Z', line)
            if matchobj:
                self.inst_id = matchobj.group(1)
                return
        else:
            print("Error: can not find the instance number in SQL*Plus output>>>")
            print(out)
            sys.exit(1)

    def check_inst_name(self, out):
        for line in out:
            matchobj = re.match(r'\AINST_NAME:([\S]+):\Z', line)
            if matchobj:
                self.inst_name = matchobj.group(1)
                return
        else:
            print("Error: can not find the instance name in SQL*Plus output>>>")
            print(out)
            sys.exit(1)

    def check_exa(self, out):
        for line in out:
            matchobj = re.match(r'\ACELL_COUNT:([\d]+):\Z', line)
            if matchobj:
                self.cell_count = int(matchobj.group(1))
                return
        else:
            print("Error: can not find the cell count in SQL*Plus output>>>")
            print(out)
            sys.exit(1)

    def is_exa(self):
        return self.cell_count > 0

    def is_cdb(self):
        return self.cdb

    def check_min_snap_id(self, out):
        for line in out:
            matchobj = re.match(r'\Afound min snap_id:([\d]+):\Z', line)
            if matchobj:
                self.min_snap_id = matchobj.group(1)
                return
        else:
            print("Error: can not find the min snap ID in SQL*Plus output>>>")
            print(out)
            sys.exit(1)

    def check_max_snap_id(self, out):
        for line in out:
            matchobj = re.match(r'\Afound max snap_id:([\d]+):\Z', line)
            if matchobj:
                self.max_snap_id = matchobj.group(1)
                return
        else:
            print("Error: can not find the max snap ID in SQL*Plus output>>>")
            print(out)
            sys.exit(1)

    def check_min_snap_time(self, out):
        for line in out:
            matchobj = re.match(r'\Afound begin time#(.+)#\Z', line)
            if matchobj:
                self.begin_time = matchobj.group(1)
                return
        else:
            print("Error: can not find the min snap time in SQL*Plus output>>>")
            print(out)
            sys.exit(1)

    def check_max_snap_time(self, out):
        for line in out:
            matchobj = re.match(r'\Afound end time#(.+)#\Z', line)
            if matchobj:
                self.end_time = matchobj.group(1)
                return
        else:
            print("Error: can not find the max snap time in SQL*Plus output>>>")
            print(out)
            sys.exit(1)

    def check_rac(self, out):
        for line in out:
            matchobj = re.match(r'\ARAC:(.+):\Z', line)
            if matchobj:
                self.is_rac = True if matchobj.group(1) == "TRUE" else False
                return
        else:
            print("Error: can not find the cluster_database value in SQL*Plus output>>>")
            print(out)
            sys.exit(1)

    def check_cdb(self):
        stmts = """
alter session set nls_language = 'AMERICAN';
select 'CDB' || ':' || cdb || ':' my_cdb from v$database;
"""
        sql = SqlPlus(stmts)
        out = sql.run()
        for line in out:
            matchobj = re.match(r'\ACDB:(.+):\Z', line)
            if matchobj:
                self.cdb = True if matchobj.group(1) == "YES" else False
                return
        else:
            print("Error: can not find the cdb value in SQL*Plus output>>>")
            print(out)
            sys.exit(1)

    @staticmethod
    def select_dbid_instance_rac():
        return """
alter session set nls_language = 'AMERICAN';
select 'DB_ID' || ':' || dbid || ':' my_dbid from v$database;
select 'INST_ID' || ':' || instance_number || ':' my_inst_id from v$instance;
select 'INST_NAME' || ':' || instance_name || ':' my_inst_name from v$instance;
select 'RAC' || ':' || value || ':' my_rac from v$system_parameter where name = 'cluster_database';
select 'CELL_COUNT' || ':' || count(*) || ':' cell_cnt from v$cell;
"""

    def select_properties(self):
        stmts = self.select_dbid_instance_rac()
        sql = SqlPlus(stmts)
        out = sql.run()
        self.check_version(out)
        self.check_db_id(out)
        self.check_inst_id(out)
        self.check_inst_name(out)
        self.check_rac(out)
        if self.major_version > 11:
            self.check_cdb()
        self.cdb_prefix = "cdb" if self.is_cdb() else "non_cdb"
        self.cdb_prefix = "%s/" % self.cdb_prefix
        self.check_exa(out)
        print(">>> Selecting database parameters and configuration...")

    def select_min_max_snap_ids(self):
        instance = 0 if self.is_rac else self.inst_id
        if self.interval_ids:
            stmts = ('@check_min_max_snap_ids.sql "%s" "%s" "%s" "%s" "%s"\n' %
                     (self.out_dir, self.begin_snap_id, self.end_snap_id,
                      self.db_id, instance))
        else:
            stmts = ('@get_min_max_snap_ids.sql "%s" "%s" "%s" "%s" "%s"\n' %
                     (self.out_dir, self.begin_time, self.end_time,
                      self.db_id, instance))
        sql = SqlPlus(stmts)
        out = sql.run()
        print(">>> Selecting min and max AWR snapshot IDs from AWR...")
        self.check_min_snap_id(out)
        self.check_max_snap_id(out)
        if self.interval_ids:
            self.check_min_snap_time(out)
            self.check_max_snap_time(out)
            print("-  Min snap ID: %s Begin snapshot ID: %s (Begin time: %s)" %
                  (self.begin_snap_id, self.min_snap_id, self.begin_time))
            print("-  Max snap ID: %s End snapshot ID  : %s (End time  : %s)" %
                  (self.end_snap_id, self.max_snap_id, self.end_time))
        else:
            print("-  Begin time: %s Begin snapshot ID: %s" %
                  (self.begin_time, self.min_snap_id))
            print("-  End time  : %s End snapshot ID  : %s" %
                  (self.end_time, self.max_snap_id))

    def check_rac_instances(self, out):
        ret = []
        for line in out:
            matchobj = re.match(r'\AINST_ID:([\d]+):\Z', line)
            if matchobj:
                ret.append(matchobj.group(1))

        if not ret:
            print("Error: can not find RAC instances in SQL*Plus output>>>")
            print(out)
            sys.exit(1)

        if self.verbose():
            print("Found RAC instances>>>", ret)

        return ret

    def select_rac_instances(self):
        stmts = ("select distinct 'INST_ID' || ':' || instance_number || ':'" +
                 " from dba_hist_snapshot where dbid = " + self.db_id +
                 " and snap_id between " + self.min_snap_id + " and " +
                 self.max_snap_id + ";\n")
        sql = SqlPlus(stmts)
        out = sql.run()
        return self.check_rac_instances(out)

    def set_in_instance_ids(self, param_inst_ids=None):
        in_inst_ids = ""
        if self.is_rac:
            avail_inst_ids = self.select_rac_instances()
            if param_inst_ids:
                for inst_id in param_inst_ids:
                    if inst_id not in avail_inst_ids:
                        print("Error: wrong values for parameter instance IDs.")
                        print("Available instance IDs: ", ','.join(avail_inst_ids))
                        print("Specified instance IDs: " + ','.join(param_inst_ids))
                        sys.exit(1)
                else:
                    in_inst_ids = "(" + ','.join(param_inst_ids) + ")"
            else:
                in_inst_ids = "(" + ','.join(avail_inst_ids) + ")"
        else:
            if param_inst_ids:
                if (len(param_inst_ids) > 1 or
                        param_inst_ids[0] != self.inst_id):
                    print("Error: wrong values for parameter instance IDs.")
                    print("Current instance IDs: ", self.inst_id)
                    print("Specified instance IDs: " + ','.join(param_inst_ids))
                    sys.exit(1)
            else:
                in_inst_ids = "(" + self.inst_id + ")"

        self.in_inst_ids = in_inst_ids

    def add_content_by_release(self):
        entities = {"11g": ("dba_hist_database_instance",
                            "dba_hist_dyn_remaster_stats",
                            "dba_hist_current_block_server"),
                    "12_1": ("dba_hist_database_instance",
                             "dba_hist_dyn_remaster_stats",
                             "dba_hist_current_block_server"),
                    "12_2": ("dba_hist_database_instance",
                             "dba_hist_dyn_remaster_stats",
                             "dba_hist_current_block_server"),
                    "18c": ("dba_hist_database_instance",
                            "dba_hist_dyn_remaster_stats",
                            "dba_hist_current_block_server"),
                    "19c": ("dba_hist_database_instance",
                            "dba_hist_dyn_remaster_stats",
                            "dba_hist_current_block_server"),
                    }
        fout = open(self.content_file_name, 'a')
        for line in entities[self.version]:
            fout.write('%s\n' % line)
        fout.close()

    def export_data_by_release(self):
        stmts = ('@%sexport_data_%s.sql "%s" "%s" "%s" "%s" "%s" %s %s\n' %
                 (self.cdb_prefix, self.version, self.out_dir, self.db_id,
                  self.in_inst_ids, self.begin_time, self.end_time,
                  self.min_snap_id, self.max_snap_id))
        sql = SqlPlus(stmts)
        sql.run()
        self.add_content_by_release()

    def write_agraf_component(self, component, flag, file_mode='a'):
        fout = open(self.components_file_name, file_mode)
        fout.write('%s;%s\n' % (component, flag))
        fout.close()

    def write_agraf_components(self, components):
        self.write_agraf_component('rdbms version', self.get_version())
        self.write_agraf_component('cdb', ("yes" if self.is_cdb() else "no"))
        self.write_agraf_component('rac', ("yes" if self.is_rac else "no"))
        self.write_agraf_component('exadata', ("yes" if self.is_exa() else "no"))
        if "seg" in components:
            self.write_agraf_component('segments', 'yes')
        else:
            self.write_agraf_component('segments', 'no')

    def write_argraf_arguments(self):
        if self.begin_time:
            self.write_agraf_component("begin_time", self.begin_time)
        if self.begin_snap_id:
            self.write_agraf_component("begin_snap_id", self.begin_snap_id)
        if self.end_time:
            self.write_agraf_component("end_time", self.end_time)
        if self.end_snap_id:
            self.write_agraf_component("end_snap_id", self.end_snap_id)
        self.write_agraf_component("min_snap_id", self.min_snap_id)
        self.write_agraf_component("max_snap_id", self.max_snap_id)

    def write_agraf_reports(self, args):
        if args.is_all() or 'awr' in args.get_report_type():
            self.write_agraf_component('awr', 'yes')

        if args.is_all() or 'addm' in args.get_report_type():
            self.write_agraf_component('addm', 'yes')

        if 'sql' in args.get_report_type():
            self.write_agraf_component('awrsql', 'yes')

    def add_content(self, line, file_mode='a'):
        fout = open(self.content_file_name, file_mode)
        fout.write('%s\n' % line)
        fout.close()

    def add_cdb_content(self):
        self.add_shared_content()
        fout = open(self.content_file_name, 'a')
        entities = ["dba_cdb_users",
                    "dba_hist_pdb_in_snap",
                    "dba_hist_pdb_instance",
                    "dba_hist_con_sys_time_model",
                    "dba_hist_con_system_event",
                    "dba_hist_con_sysstat", "v$pdbs",
                    "pdb_spfile$",
                    ]
        for line in entities:
            fout.write('%s\n' % line)
        fout.close()

    def add_shared_content(self):
        fout = open(self.content_file_name, 'a')
        entities = ["dba_hist_wr_control", "dba_hist_snapshot",
                    "dba_hist_sys_time_model", "dba_hist_system_event",
                    "dba_hist_sysstat", "dba_hist_active_sess_history",
                    "dba_hist_thread", "dba_hist_pgastat",
                    "dba_hist_iostat_function", "dba_hist_filestatxs",
                    "dba_hist_tempstatxs", "dba_hist_sqlstat",
                    "dba_hist_sqltext", "dba_hist_sysmetric_summary",
                    "dba_hist_osstat", "dba_hist_parameter",
                    "v$spparamerter", "dba_hist_cr_block_server",
                    "dba_hist_ic_client_stats", "dba_hist_interconnect_pings",
                    "dba_hist_inst_cache_transfer", "dba_hist_undostat",
                    "v$log", "v$standby_log", "v$logfile",
                    "dba_hist_instance_recovery",
                    "dba_hist_process_mem_summary", "dba_hist_log",
                    ]
        for line in entities:
            fout.write('%s\n' % line)
        fout.close()

    def add_non_cdb_content(self):
        self.add_shared_content()
        fout = open(self.content_file_name, 'a')
        entities = ["dba_users",
                    ]
        for line in entities:
            fout.write('%s\n' % line)
        fout.close()

    def export_data(self, components):
        stmts = ('@%sexport_data.sql "%s" "%s" "%s" "%s" "%s" %s %s\n' %
                 (self.cdb_prefix, self.out_dir, self.db_id, self.in_inst_ids,
                  self.begin_time, self.end_time,
                  self.min_snap_id, self.max_snap_id))
        sql = SqlPlus(stmts)
        sql.run()
        if self.is_cdb():
            self.add_cdb_content()
        else:
            self.add_non_cdb_content()

        self.export_data_by_release()
        self.export_os_data()
        self.export_exa_data()
        self.export_segments(components)
        self.write_agraf_components(components)
        print(">>> Export was done successfully.")
        self.compress_export_data()

    def compress_export_data(self):
        tar_file = create_tar_file_name(self.out_dir, "data", self.inst_name,
                                        self.interval_string(), self.cdb)
        rc = os.system("cd %s; tar zcf %s *.log *.csv *.txt" %
                       (self.out_dir, tar_file))
        if rc:
            print("Errors occurred during creating the tar archive.")
            sys.exit(1)

        print(">>> The tar archive " + tar_file +
              " with exported data is ready.")

    def check_linux_release(self):
        release_files = ['/etc/oracle-release', '/etc/redhat-release',
                         '/etc/SuSE-release']
        for my_file in release_files:
            if os.path.exists(my_file):
                shutil.copyfile(my_file, "%s/%s.log" %
                                (self.out_dir, os.path.split(my_file)[1]))
                self.add_content(my_file)

    def export_linux_details(self):
        if sys.platform.startswith('linux'):
            os.system("cat /proc/cpuinfo > %s/cpuinfo.log" % self.out_dir)
            self.add_content("/proc/cpuinfo")
            os.system("cat /proc/meminfo > %s/meminfo.log" % self.out_dir)
            self.add_content("/proc/meminfo")

        self.check_linux_release()

        os.system("uname -a > %s/uname_a.log" % self.out_dir)
        self.add_content("uname -a")

    def export_os_data(self):
        self.export_linux_details()

    def export_exa_data(self):
        if self.is_exa():
            stmts = ('@%sexport_data_exa.sql "%s" "%s" "%s" "%s" "%s" %s %s\n' %
                     (self.cdb_prefix, self.out_dir, self.db_id, self.in_inst_ids,
                      self.begin_time, self.end_time,
                      self.min_snap_id, self.max_snap_id))
            sql = SqlPlus(stmts)
            sql.run()
            self.add_content("v$cell")
        else:
            os.system("touch %s/hist_exa_sysstat.csv" % self.out_dir)
            os.system("touch %s/hist_exa_con_sysstat.csv" % self.out_dir)

    def export_segments(self, components):
        if "seg" in components:
            stmts = ('@%sexport_segments.sql "%s" "%s" "%s" "%s" "%s" %s %s\n' %
                     (self.cdb_prefix, self.out_dir, self.db_id, self.in_inst_ids,
                      self.begin_time, self.end_time,
                      self.min_snap_id, self.max_snap_id))
            sql = SqlPlus(stmts)
            sql.run()
            self.add_content("dba_hist_seg_stat")
            self.add_content("dba_hist_seg_stat_obj")
        else:
            os.system("touch %s/hist_seg_stat.csv" % self.out_dir)
            os.system("touch %s/hist_seg_stat_obj.csv" % self.out_dir)

    @staticmethod
    def read_snap_ids(out):
        res = dict()
        pattern = re.compile(r'SNAP_ID:([\d]+:\d+:.*):\Z')
        for line in out:
            matchobj = pattern.search(line)
            if matchobj:
                (snap_id_str, snap, inst, end_date, others) = line.split(':')
                if inst in res:
                    res[inst].append((snap, end_date))
                else:
                    res[inst] = [(snap, end_date)]

        return res

    def select_awr_report_snap_ids(self):
        stmts = "set pagesi 0 linesi 255 trimsp on heading on\n"
        stmts += ("select 'SNAP_ID' || ':' || snap_id || ':' || " +
                  "instance_number || ':' || \n  to_char(end_interval_time" +
                  ", 'dd-mon_hh24-mi-ss') || ':' \nfrom dba_hist_snapshot\n" +
                  "where dbid = " + self.db_id + " and\nsnap_id between " +
                  self.min_snap_id + " and " + self.max_snap_id +
                  " and \n instance_number in " + self.in_inst_ids + "\n" +
                  "order by instance_number, snap_id\n/\n")
        sql = SqlPlus(stmts)
        out = sql.run()
        return self.read_snap_ids(out)

    def export_awr_reports(self, formats, snap_ids, parallel=None,
                           summary=False, summary_only=False):
        awr = AwrReports(self.db_id, self.inst_name, self.out_dir,
                         formats, snap_ids, parallel)
        awr.generate_reports(self.interval_string(), summary, summary_only)

    def export_addm_reports(self, snap_ids,
                            summary=False, summary_only=False):
        addm = AddmReports(self.db_id, self.inst_name, self.out_dir, snap_ids)
        addm.generate_reports(self.interval_string(), summary, summary_only)

    def export_sql_reports(self, formats, snap_ids, sql_ids, parallel=None,
                           summary=False, summary_only=False):
        sql = AwrSqlReports(self.db_id, self.inst_name, self.out_dir,
                            formats, snap_ids, sql_ids, parallel)
        if self.verbose():
            print(sql)
        sql.generate_reports(self.interval_string(), summary, summary_only)


class SqlPlus:
    def __init__(self, stmts=None, sql_file=None,
                 log_file=None, cmd=None, is_verbose=False):
        self.stmts = stmts
        self.sql_file = sql_file
        self.sql_file_prefix = "agraf_sqlplus_%s" % os.getpid()
        self.log_file = log_file
        self.cmd = cmd
        self.is_verbose = is_verbose

    def __str__(self):
        ret = "Class SqlPlus:\n"
        if self.stmts:
            ret += "- stmts: %s\n" % self.stmts
        if self.sql_file:
            ret += "- sql_file: %s\n" % self.sql_file
        if self.sql_file_prefix:
            ret += "- sql_file_prefix: %s\n" % self.sql_file_prefix
        if self.log_file:
            ret += "- log_file: %s\n" % self.log_file
        if self.cmd:
            ret += "- cmd: %s\n" % self.cmd

        return ret

    def verbose(self):
        return self.is_verbose

    def create_sql_file(self, do_exit=True):
        fd, self.sql_file = tempfile.mkstemp('.sql', self.sql_file_prefix)

        if do_exit:
            os.write(fd, "whenever sqlerror exit failure\n")
            os.write(fd, "whenever oserror exit failure\n")

        os.write(fd, "connect / as sysdba\n")
        if self.verbose():
            os.write(fd, "set echo on verify on\n")
        else:
            os.write(fd, "set echo off verify off\n")
        os.write(fd, self.stmts + "\n" + "exit\n")
        os.close(fd)

    def exit_on_error(self, out):
        print("SQL script for SQL*Plus>>>")
        for line in open(self.sql_file):
            print(line, end='')

        print("\n\nSQL*Plus output>>>")
        for line in out:
            print(line, end='')

        sys.exit(1)

    def run(self, do_exit=True):
        if self.sql_file is None:
            self.create_sql_file(do_exit)

        if self.verbose():
            print("SQL script for SQL*Plus>>>")
            for line in open(self.sql_file):
                print(line, end='')

        cmd = self.cmd + ';' if self.cmd else ''
        cmd += 'sqlplus /nolog < ' + self.sql_file + ' 2>&1'
        out = []
        try:
            fp = os.popen(cmd)
            out = fp.readlines()
            rc = fp.close()

            if rc and do_exit:
                print("Error: SQL*Plus returns with error code %d." % rc)
                self.exit_on_error(out)

        except Exception as e:
            if do_exit:
                print('Error: Unexpected error during running SQL*Plus: ', e)
                print(e)
                self.exit_on_error(out)

        finally:
            os.remove(self.sql_file)

        if self.verbose():
            print("SQL*Plus output>>>")
            for line in out:
                print(line, end='')

        return [x.strip() for x in out]
