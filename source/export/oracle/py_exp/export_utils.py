#!/usr/bin/python
#
# Author: Andrej Simon, Oracle ACS Germany
#
# This Python module contains help functions.

import socket


def get_hostname():
    my_host = socket.gethostname()
    if my_host.find('.') > 0:
        my_host = my_host.split('.')[0]

    return my_host


def create_tar_file_name(my_dir, prefix, instance, suffix, is_cdb=False):
    cdb = "cdb_" if is_cdb else ""
    tar_file = "%s/agraf_%s_%s%s_%s_%s.tar.gz" % (my_dir, prefix, cdb,
                                                  get_hostname(), instance, suffix)
    return tar_file
