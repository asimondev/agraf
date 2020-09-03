#!/usr/bin/python
#
# Author: Andrej Simon, Oracle ACS Germany
#
# This Python module contains help functions.

import os
import socket
import sys


def get_hostname():
    my_host = socket.gethostname()
    if my_host.find('.') > 0:
        my_host = my_host.split('.')[0]

    return my_host


def create_tar_file_name(my_dir, prefix, instance, suffix, is_cdb=False):
    cdb = "cdb_" if is_cdb else ""
    file_type = "tar.gz" if sys.platform.startswith("linux") else "tar"
    tar_file = "%s/agraf_%s_%s%s_%s_%s.%s" % (my_dir, prefix, cdb,
                                              get_hostname(), instance, suffix, file_type)
    return tar_file


def get_tar_option():
    return "zcf" if sys.platform.startswith('linux') else "cf"


def create_tar(tar_file, cmd):
    is_linux = sys.platform.startswith('linux')
    rc = os.system(cmd)
    if rc:
        print("Errors occurred during creating the tar archive %s." % tar_file)
        sys.exit(1)

    if not is_linux:
        rc = os.system("gzip %s" % tar_file)
        if rc:
            print("Errors occurred during compressing the tar archive %s." % tar_file)
            sys.exit(1)
        tar_file += ".gz"

    return tar_file
