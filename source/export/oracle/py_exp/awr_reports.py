#!/usr/bin/python
#
# Author: Andrej Simon, Oracle ACS Germany
#
# This Python module contains AwrReports class, which exports AWR reports from
# Oracle database.

from __future__ import print_function

import multiprocessing
import os
import sys
from time import strftime

from export_utils import create_tar_file_name
import database
# from database import SqlPlus


class AwrReports:
    def __init__(self, db_id, inst_name, out_dir, formats, snap_ids, parallel=None):
        self.db_id = db_id
        self.inst_name = inst_name
        self.out_dir = out_dir
        self.formats = formats
        self.snap_ids = snap_ids
        self.awr_dir = "awr_reports_%s" % strftime("%Y-%m-%d_%H-%M-%S")
        self.parallel = parallel

    def __str__(self):
        ret = "Class AwrReports:\n"
        ret += "- db_id: %s\n" % self.db_id
        ret += "- inst_name: %s\n" % self.inst_name
        ret += "- out_dir: %s\n" % self.out_dir
        ret += "- awr_dir: %s\n" % self.awr_dir
        ret += "- formats: %s\n" % ','.join(self.formats)
        if self.parallel is not None:
            ret += "- parallel: %s\n" % self.parallel

        return ret

    def compress_awr_reports(self, suffix):
        tar_file = create_tar_file_name(self.out_dir, "awr_reports",
                                        self.inst_name, suffix)
        rc = os.system("cd %s; tar zcf %s %s" %
                       (self.out_dir, tar_file, self.awr_dir))
        if rc:
            print("Errors occurred during creating the tar archive.")
            sys.exit(1)

        print(">>> The tar archive " + tar_file +
              " with AWR reports is ready.")

    def prepare_awr_report(self, fmt, inst, snap_id, my_dir, my_args, summary):
        if summary:
            cur_id = len(self.snap_ids[inst]) - 1
            prev_id = 0
        else:
            cur_id = snap_id
            prev_id = snap_id - 1

        if self.parallel:
            my_args.append((fmt, self.db_id, inst, self.snap_ids[inst][prev_id][0],
                            self.snap_ids[inst][cur_id][0],
                            self.snap_ids[inst][cur_id][1], my_dir))
        else:
            generate_awr_report(fmt, self.db_id, inst,
                                self.snap_ids[inst][prev_id][0],
                                self.snap_ids[inst][cur_id][0],
                                self.snap_ids[inst][cur_id][1], my_dir)

    def generate_reports(self, suffix, summary=False, summary_only=False):
        my_dir = "%s/%s" % (self.out_dir, self.awr_dir)
        if not os.path.isdir(my_dir):
            os.mkdir(my_dir)

        my_args = []
        print("\n>>> Generating AWR reports...")
        for fmt in self.formats:
            for inst in self.snap_ids:
                if summary_only:
                    self.prepare_awr_report(fmt, inst, 0, my_dir, my_args, True)
                else:
                    for snap_id in range(1, len(self.snap_ids[inst])):
                        self.prepare_awr_report(fmt, inst, snap_id, my_dir, my_args, False)

                    if summary:
                        self.prepare_awr_report(fmt, inst, 0, my_dir, my_args, True)

        if self.parallel:
            pool = multiprocessing.Pool(processes=self.parallel)
            pool.map(run_awr_parallel, my_args)
            pool.close()

        print(">>> AWR reports were generated into the following directory:")
        print("    ", my_dir)
        self.compress_awr_reports(suffix)


def generate_awr_report(report_type, db_id, inst_id,
                        start_id, end_id, end_date, awr_dir):
    report_name = "agraf_awr_%s_%s_%s_%s.%s" % (inst_id,
                                                start_id, end_id, end_date, report_type)
    stmts = """
define inst_num=%s
define num_days=1
define dbid=%s
define begin_snap=%s
define end_snap=%s
define report_type=%s
define report_name=%s
@?/rdbms/admin/awrrpti.sql
""" % (inst_id, db_id, start_id, end_id, report_type, report_name)
    cmd = "cd %s" % awr_dir

    sql = database.SqlPlus(stmts, cmd=cmd)
    sql.run(do_exit=False)


def run_awr_parallel(args):
    generate_awr_report(*args)

