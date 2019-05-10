# -*- coding: utf-8 -*-
"""
Created on Thu Apr 25 11:55:36 2019
SQL exercise
@author: Shubham
"""

import sys
import pymysql
import logger

conn = None

def openConnection():
    global conn
    try:
        name = 'student'
        password = 'learn_sql@springboard'
        db_name = 'country_club'
        if(conn is None):
            conn = pymysql.connect('localhost', user=name, passwd=password, db=db_name, connect_timeout=5)
        elif (not conn.open):
            conn = pymysql.connect('localhost', user=name, passwd=password, db=db_name, connect_timeout=5)    
    except:
        logger.error("ERROR: Unexpected error: Could not connect to MySql instance.")
        sys.exit()




    