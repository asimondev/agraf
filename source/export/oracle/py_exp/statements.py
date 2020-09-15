#!/usr/bin/python

from __future__ import print_function

import os
import sys

from export_utils import get_hostname
import database


class Statements:
    def __init__(self, cdb_prefix, db_id, in_inst_ids,
                 min_snap_id, max_snap_id, out_dir):
        self.cdb_prefix = cdb_prefix
        self.db_id = db_id
        self.in_inst_ids = in_inst_ids
        self.min_snap_id = min_snap_id
        self.max_snap_id = max_snap_id
        self.out_dir = out_dir

    def __str__(self):
        ret = "Class Statements:\n"
        ret += "- cdb_prefix: %s\n" % self.cdb_prefix
        ret += "- db_id: %s\n" % self.db_id
        ret += "- in_inst_id: %s\n" % self.in_inst_ids
        ret += "- min_snap_id: %s\n" % self.min_snap_id
        ret += "- max_snap_id: %s\n" % self.max_snap_id
        ret += "- out_dir: %s\n" % self.out_dir

        return ret

    def write_statements(self, suffix, instance):
        print("\n>>> Writing SQL statements...")

        if not os.path.isdir(self.out_dir):
            os.mkdir(self.out_dir)

        file_name = "%s/agraf_statements_%s_%s_%s.txt" % (self.out_dir,
                            get_hostname(), instance, suffix)

        stmts = ('@non_cdb/write_dba_hist_sqltext_clobs.sql "%s" "%s" "%s" %s %s\n' %
                 (file_name, self.db_id, self.in_inst_ids,
                  self.min_snap_id, self.max_snap_id))
        sql = database.SqlPlus(stmts)
        sql.run()

        self.compress_statements(file_name)

    def compress_statements(self, file_name):
        rc = os.system("gzip -f " + file_name)
        if rc:
            print("Errors occurred during compressing the file %s." %
                  file_name)
            sys.exit(1)

        file_name += ".gz"
        print(">>> The SQL statements file " + file_name +
              " is ready.")
