#!/usr/bin/python
#
# Author: Andrej Simon, Oracle ACS Germany
#
# This is the main script to start export of AWR data. Use this file with Python2.
#

from __future__ import print_function
from __future__ import absolute_import

from py_exp.awr_export import start_export

if __name__ == '__main__':
    start_export()
