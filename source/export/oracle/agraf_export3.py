#!/usr/bin/python3
#
# Author: Andrej Simon, Oracle ACS Germany
#
# This is the main script to start export of AWR data. Use this file with Python3.
#

from py_exp.awr_export import start_export

if __name__ == '__main__':
    start_export()
