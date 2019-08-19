#!/usr/bin/python
#
# Author: Andrej Simon, Oracle ACS Germany
#
# This is the main script to start export of AWR statistics using
# SQL*Plus in CSV files. There is one CSV file for each SELECT of the
# DBA_HIST_xxx table.
#
#
# Example: agraf_export.py -b "2018-11-20 08:00" -e "2018-11-25 20:00"
#

from __future__ import print_function

import multiprocessing
import optparse
import os
import re
import sys
from time import strftime

from py_exp.export_utils import get_hostname
from py_exp.database import Database

# Version a.b.c.d:
#   a - Main version number
#   b - Database changes
#   c - Grafana changes
#   d - Code changes
AGRAF_VERSION = "1.4.2.4"

#######################################################################
verbose_flag = False


def set_verbose(flag):
    global verbose_flag
    verbose_flag = flag


def verbose():
    return verbose_flag


def parse_args():
    parser = optparse.OptionParser(version="%prog " + AGRAF_VERSION)
    parser.add_option("-a", "--all", help="Export AWR and ADDM reports",
                      action="store_true", dest="all", default=False)
    parser.add_option("-b", "--begin_time",
                      help="begin time. Format: {yyyy-mm-dd hh24:mi | yyyy-mm-dd | hh24:mi}")
    parser.add_option("-c", "--components",
                      help="Export components: {seg|noseg}")
    parser.add_option("-e", "--end_time",
                      help="end time. Format: {yyyy-mm-dd hh24:mi | yyyy-mm-dd | hh24:mi | now}")
    parser.add_option("-f", "--format",
                      help="AWR and ADDM report format: text, html, active-html")
    parser.add_option("-i", "--instance_id",
                      help="instance ID")
    parser.add_option("-n", "--min_snap_id", help="min snap ID",
                      type=int)
    parser.add_option("-o", "--output_dir",
                      help="output directory")
    parser.add_option("-p", "--parallel", help="Number of parallel AWR/ADDM reports",
                      type=int)
    parser.add_option("-r", "--report",
                      help="Reports: nodata, AWR, ADDM, SQL")
    parser.add_option("--summary", help="Create summary reports",
                      action="store_true", dest="summary", default=False)
    parser.add_option("--summary_only", help="Create only summary reports",
                      action="store_true", dest="summary_only", default=False)
    parser.add_option("-s", "--sql_id",
                      help="sql_id(s) for AWR SQL report(s)")
    parser.add_option("-x", "--max_snap_id", help="max snap ID",
                      type=int)
    parser.add_option("-v", "--verbose", help="verbose",
                      action="store_true", dest="verbose", default=False)

    (options, args) = parser.parse_args()
    prog_args = ProgArgs(begin_time=options.begin_time,
                         end_time=options.end_time,
                         begin_snap_id=options.min_snap_id,
                         end_snap_id=options.max_snap_id,
                         out_dir=options.output_dir,
                         instance=options.instance_id,
                         is_verbose=options.verbose,
                         all_reports=options.all,
                         report_format=options.format,
                         report_type=options.report,
                         parallel=options.parallel,
                         components=options.components,
                         summary=options.summary,
                         summary_only=options.summary_only,
                         sql_id=options.sql_id)
    prog_args.check_args()

    return prog_args


def usage():
    print("\nParameters: {-b Begin_Time -e End_Time | -n Min_Snap_ID -x Max_Snap_ID}")
    print("  [-o Output_Dir] [-i Instance_ID[,Instance_id]] [-r nodata,AWR,ADDM,SQL]")
    print("  [-f text,html,activ-html] [-a -v {--summary | --summary_only}]")
    print("  [-s SQL_ID[,SQL_ID] [-p Parallel] [--version]")
    print("Time format: {yyyy-mm-dd hh24:mi | yyyy-mm-dd | hh24:mi | now}.")
    print("  Time format example: 2018-12-31 11:11")


def os_exit(out):
    for line in out:
        print(line, end='')
    sys.exit(1)


#######################################################################
class ProgArgs:
    def __init__(self, begin_time=None, end_time=None,
                 begin_snap_id=None, end_snap_id=None,
                 out_dir=None, is_verbose=None, instance=None,
                 all_reports=None, report_type=None,
                 report_format=None, parallel=None,
                 components=None, sql_id=None,
                 summary=None, summary_only=None):
        self.begin_time = begin_time
        self.end_time = end_time
        self.begin_snap_id = begin_snap_id
        self.end_snap_id = end_snap_id
        self.interval_ids = None

        self.out_dir = out_dir
        self.instance = instance
        self.inst_ids = []

        self.all_reports = all_reports
        self.report_type = report_type
        self.report_format = report_format
        self.summary = True if summary else False
        self.summary_only = True if summary_only else False
        self.sql_id = sql_id
        self.sql_ids = []

        self.verbose = is_verbose
        set_verbose(False if is_verbose is None else is_verbose)
        self.parallel = parallel
        self.components = components

    def __str__(self):
        ret = "Class MyArgs:\n"
        if self.begin_time:
            ret += "- begin_time: %s\n" % self.begin_time
        if self.end_time:
            ret += "- end_time: %s\n" % self.end_time
        if self.begin_snap_id:
            ret += "- begin_snap_id: %s\n" % self.begin_snap_id
        if self.end_snap_id:
            ret += "- end_snap_id: %s\n" % self.end_snap_id
        if self.out_dir:
            ret += "- out_dir: %s\n" % self.out_dir
        if self.inst_ids:
            ret += "- inst_ids: %s\n" % ','.join(self.inst_ids)
        if self.verbose:
            ret += "- verbose: %s\n" % self.verbose
        if self.all_reports:
            ret += "- all: %s\n" % self.all_reports
        if self.report_type:
            ret += "- report type: %s\n" % ','.join(self.report_type)
        if self.report_format:
            ret += "- report format: %s\n" % ','.join(self.report_format)
        if self.parallel:
            ret += "- parallel: %s\n" % self.parallel
        if self.components:
            ret += "- components: %s\n" % self.components
        if self.sql_ids:
            ret += "- sql_id(s): %s\n" % ','.join(self.sql_ids)
        if self.summary:
            ret += "- summary: %s\n" % self.summary
        if self.summary_only:
            ret += "- summary_only: %s\n" % self.summary_only

        return ret

    def check_instance_ids(self):
        if self.instance:
            return True

        for inst_id in self.instance.split(','):
            self.inst_ids.append(int(inst_id))

        return True

    def check_output_directory(self):
        if self.out_dir is None:
            self.out_dir = os.getcwd()
        else:
            if not os.path.isdir(self.out_dir):
                print("Error: wrong output directory '%s'" %
                      self.out_dir)
                usage()
                sys.exit(1)

        self.out_dir = os.path.normpath(self.out_dir)

    def check_report_format(self):
        if self.report_format:
            res = set(self.report_format.split(','))
            valid = True
            if res:
                formats = set(["html", "text", "active-html"])
                if res - formats:
                    valid = False
            else:
                valid = False

            if valid:
                return list(res)
            else:
                print('Error: wrong format type "--format %s".' %
                      self.report_format)
                print("Possible formats are text, html, active-html")
                sys.exit(1)

        return ["html"]

    def check_report_type(self):
        if self.report_type:
            lst = [x.lower() for x in self.report_type.split(',')]
            res = set(lst)
            valid = True
            if res:
                formats = set(["nodata", "awr", "addm", "sql"])
                if res - formats:
                    valid = False
            else:
                valid = False

            if valid:
                return list(res)
            else:
                print('Error: wrong report type "--report %s".' %
                      self.report_type)
                print("Possible reports are nodata, AWR, ADDM, SQL.")
                sys.exit(1)

        return []

    # At the moment only seg or noseg are allowed.
    def check_components(self):
        if self.components:
            res = set(self.components.split(','))
            valid = True
            if res:
                formats = set(["seg", "noseg"])
                if res - formats:
                    valid = False
            else:
                valid = False

            if valid and len(res) == 1:  # Either seg or noseg
                return list(res)
            else:
                print('Error: wrong export components "--components %s".' %
                      self.components)
                print("Possible components: {seg | noseg}")
                sys.exit(1)

        return ["noseg"]

    def check_interval(self):
        valid = True

        if (self.begin_time is None and self.end_time is None and
                self.begin_snap_id is None and self.end_snap_id is None):
            print("Error: time interval not found.")
            valid = False

        elif self.begin_time is not None or self.end_time is not None:
            ts = TimeStamp(self.begin_time, False, "begin time")
            self.begin_time = ts.check()
            if self.begin_time is None:
                valid = False

            if valid:
                ts = TimeStamp(self.end_time, True, "end time")
                self.end_time = ts.check()
                if self.end_time is None:
                    valid = False

            self.interval_ids = False if valid else None

        elif self.begin_snap_id is not None or self.end_snap_id is not None:
            if self.begin_snap_id is None:
                print("Error: mandatory parameters begin snap ID not found.")
                valid = False

            if valid:
                if self.end_snap_id is None:
                    print("Error: mandatory parameters end snap ID not found.")
                    valid = False

            self.interval_ids = True if valid else None

        if not valid:
            usage()
            sys.exit(1)

    def check_sql_ids(self):
        if self.sql_id is None:
            return

        if 'sql' not in self.report_type:
            print("Error: sql_id option needs SQL report type.")
            sys.exit(1)

        for sql in self.sql_id.split(','):
            self.sql_ids.append(sql)

        if not self.sql_ids:
            print("Error: sql report type needs sql_ids.")
            sys.exit(1)

    def check_summary_options(self):
        if self.summary:
            if not self.report_type:
                print("Error: --summary option needs AWR, "
                      "ADDM or SQL reports.")
                sys.exit(1)

        if self.summary_only:
            if not self.report_type:
                print("Error: --summary_only option needs AWR, "
                      "ADDM or SQL reports.")
                sys.exit(1)

        if self.summary_only and self.summary:
            print("Error: both --summary and --summary_only "
                  "options are not allowed.")
            sys.exit(1)

    def check_args(self):
        self.check_interval()
        self.check_output_directory()
        self.report_format = self.check_report_format()
        self.report_type = self.check_report_type()
        self.components = self.check_components()
        self.check_sql_ids()

        if self.parallel:
            cpus = multiprocessing.cpu_count()
            if self.parallel > cpus:
                print("Error: parallel parameter (%s) exceeded the "
                      "number of available CPUs(%s)." % (self.parallel, cpus))
                sys.exit(1)

        self.check_summary_options()

    def get_begin_time(self):
        return self.begin_time

    def get_end_time(self):
        return self.end_time

    def get_begin_snap_id(self):
        return self.begin_snap_id

    def get_end_snap_id(self):
        return self.end_snap_id

    def is_interval_ids(self):
        return self.interval_ids

    def get_output_directory(self):
        return self.out_dir

    def get_inst_ids(self):
        return self.inst_ids

    def is_all(self):
        return self.all_reports

    def get_report_type(self):
        return self.report_type

    def get_report_format(self):
        return self.report_format

    def get_parallel(self):
        return self.parallel

    def get_components(self):
        return self.components

    def get_sql_ids(self):
        return self.sql_ids

    def is_summary(self):
        return self.summary

    def is_summary_only(self):
        return self.summary_only


class TimeStamp:
    def __init__(self, date_str=None, now_allowed=False, name=None):
        self.date_str = date_str
        self.now_allowed = now_allowed
        self.name = name

    def __str__(self):
        ret = "Class TimeStamp:\n"
        if self.date_str:
            ret += "- date_str: %s\n" % self.date_str
        ret += "- now_allowed: %s\n" % self.now_allowed
        if self.name:
            ret += "- name: %s\n" % self.name

        return ret

    def check_timestamp_format(self):
        pattern = re.compile(r'\A20[12]\d-[01]\d-[0-3]\d [012]\d:[0-5]\d\Z')
        return pattern.match(self.date_str) is not None

    def check_date_format(self):
        pattern = re.compile(r'\A20[12]\d-[01]\d-[0-3]\d\Z')
        return pattern.match(self.date_str) is not None

    def check_time_format(self):
        pattern = re.compile(r'\A[012]\d:[0-5]\d\Z')
        return pattern.match(self.date_str) is not None

    def check(self):
        if self.date_str is None:
            print("Error: missing mandatory parameters %s." % self.name)
            return None

        elif self.check_date_format():
            return self.date_str + " 00:00"

        elif self.check_timestamp_format():
            return self.date_str

        elif self.check_time_format():
            return strftime("%Y-%m-%d") + " " + self.date_str

        elif self.now_allowed and self.date_str.lower() == "now":
            return strftime("%Y-%m-%d %H:%M")

        else:
            print("Error: wrong format for %s '%s'" %
                  (self.name, self.date_str))

        return None


#######################################################################
def main():
    args = parse_args()
    if verbose():
        print(args)
    db = Database(out_dir=args.get_output_directory(),
                  interval_ids=args.is_interval_ids(),
                  begin_time=args.get_begin_time(),
                  end_time=args.get_end_time(),
                  begin_snap_id=args.get_begin_snap_id(),
                  end_snap_id=args.get_end_snap_id(),
                  is_verbose=verbose()
                  )
    db.select_properties()
    db.select_min_max_snap_ids()
    db.set_in_instance_ids(args.get_inst_ids())
    db.write_agraf_component('agraf version', AGRAF_VERSION, 'w')
    db.write_agraf_component('instance name', db.inst_name)
    db.write_agraf_component('hostname', get_hostname())
    db.write_agraf_component('export timestamp', strftime("%Y-%m-%d %H:%M"))
    db.write_argraf_arguments()
    db.add_content("Export contents:", file_mode='w')

    if verbose():
        print(db)

    db.write_agraf_reports(args)
    if args.is_all() or 'nodata' not in args.get_report_type():
        db.export_data(args.get_components())

    if (args.is_all() or 'awr' in args.get_report_type() or
            'addm' in args.get_report_type() or
            'sql' in args.get_report_type()):
        snap_ids = db.select_awr_report_snap_ids()

        if args.is_all() or 'awr' in args.get_report_type():
            db.export_awr_reports(args.get_report_format(),
                                  snap_ids, args.get_parallel(),
                                  args.is_summary(), args.is_summary_only())

        if args.is_all() or 'addm' in args.get_report_type():
            db.export_addm_reports(snap_ids,
                                   args.is_summary(), args.is_summary_only())

        if 'sql' in args.get_report_type():
            db.export_sql_reports(args.get_report_format(),
                                  snap_ids, args.get_sql_ids(),
                                  args.get_parallel(),
                                  args.is_summary(), args.is_summary_only())


#######################################################################
if __name__ == '__main__':
    main()
