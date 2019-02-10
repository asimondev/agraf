#!/usr/bin/python
#
# Author: Andrej Simon, Oracle ACS Germany
#
# This Python module contains AwrReports class, which exports ADDM reports from
# Oracle database.

from __future__ import print_function

import multiprocessing
import os
import sys
from time import strftime

from export_utils import create_tar_file_name
import database


class AddmReports:
    def __init__(self, db_id, inst_name, out_dir, snap_ids, parallel=None):
        self.db_id = db_id
        self.inst_name = inst_name
        self.out_dir = out_dir
        self.snap_ids = snap_ids
        self.addm_dir = "addm_reports_%s" % strftime("%Y-%m-%d_%H-%M-%S")
        self.parallel = parallel

    def __str__(self):
        ret = "Class AddmReports:\n"
        ret += "- db_id: %s\n" % self.db_id
        ret += "- inst_name: %s\n" % self.inst_name
        ret += "- out_dir: %s\n" % self.out_dir
        ret += "- addm_dir: %s\n" % self.addm_dir
        if self.parallel is not None:
            ret += "- parallel: %s\n" % self.parallel

        return ret

    def compress_addm_reports(self, suffix):
        tar_file = create_tar_file_name(self.out_dir, "addm_reports",
                                        self.inst_name, suffix)
        rc = os.system("cd %s; tar zcf %s %s" %
                       (self.out_dir, tar_file, self.addm_dir))
        if rc:
            print("Errors occurred during creating the tar archive.")
            sys.exit(1)

        print(">>> The tar archive " + tar_file +
              " with ADDM reports is ready.")

    def prepare_addm_report(self, inst, snap_id, my_dir, my_args, summary):
        if summary:
            cur_id = len(self.snap_ids[inst]) - 1
            prev_id = 0
        else:
            cur_id = snap_id
            prev_id = snap_id - 1

        if self.parallel:
            my_args.append((self.db_id, inst, self.snap_ids[inst][prev_id][0],
                            self.snap_ids[inst][cur_id][0],
                            self.snap_ids[inst][cur_id][1], my_dir))
        else:
            generate_addm_report(self.db_id, inst,
                                 self.snap_ids[inst][prev_id][0],
                                 self.snap_ids[inst][cur_id][0],
                                 self.snap_ids[inst][cur_id][1], my_dir)

    def generate_reports(self, suffix, summary=False, summary_only=False):
        my_dir = "%s/%s" % (self.out_dir, self.addm_dir)
        if not os.path.isdir(my_dir):
            os.mkdir(my_dir)

        my_args = []
        print("\n>>> Generating ADDM reports...")
        for inst in self.snap_ids:
            if summary_only:
                self.prepare_addm_report(inst, 0, my_dir, my_args, True)
            else:
                for snap_id in range(1, len(self.snap_ids[inst])):
                    self.prepare_addm_report(inst, snap_id, my_dir, my_args, False)

                if summary:
                    self.prepare_addm_report(inst, 0, my_dir, my_args, True)

        if self.parallel:
            pool = multiprocessing.Pool(processes=self.parallel)
            pool.map(run_addm_parallel, my_args)
            pool.close()

        print(">>> ADDM reports were generated into the following directory:")
        print("    ", my_dir)
        self.compress_addm_reports(suffix)


def generate_addm_report(db_id, inst_id,
                         start_id, end_id, end_date, addm_dir):
    report_name = "agraf_addm_%s_%s_%s_%s.text" % (inst_id,
                                                   start_id, end_id, end_date)
    stmts = """
define inst_num=%s
define num_days=1
define dbid=%s
define begin_snap=%s
define end_snap=%s
define report_name=%s
@?/rdbms/admin/addmrpti.sql
""" % (inst_id, db_id, start_id, end_id, report_name)
    cmd = "cd %s" % addm_dir

    sql = database.SqlPlus(stmts, cmd=cmd)
    sql.run(do_exit=False)


def run_addm_parallel(args):
    generate_addm_report(*args)
