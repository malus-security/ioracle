#!/usr/bin/python

import sqlite3
import re
import os

location = 'logs'
table_name = 'appOutput'


def init():
    clean()
    global conn
    global c
    conn = sqlite3.connect(location)
    c = conn.cursor()
    create_database()

def create_database():
    sql = 'create table if not exists ' + table_name + ' ( \
            id INTEGER NOT NULL, \
            method TEXT NOT NULL, \
            machPort TEXT NOT NULL, \
            hasCompletion INTEGER DEFAULT 0, \
            connectionInvalidated INTEGER DEFAULT 0, \
            connectionTerminated INTEGER DEFAULT 0)'
    c.execute(sql)
    sql = 'create unique index ent_key_value on ' + table_name + ' (id, method, machPort, hasCompletion)'
    c.execute(sql)
    conn.commit()

def clean():
    os.system('rm -rf ' + location)

def insert_log(m_id, method, machPort, hasCompletion, connectionInvalidated, connectionTerminated):
    sql = "insert into " + table_name + " (id, method, machPort, hasCompletion, connectionInvalidated, connectionTerminated) values (%d, '%s', '%s', %d, %d, %d)" % (m_id, method, machPort, hasCompletion, connectionInvalidated, connectionTerminated)
    c.execute(sql)
    conn.commit()

def add_log(log_name):
    curr_dir = os.path.dirname(__file__)
    log = os.path.join(curr_dir, log_name)
    log_file = open(log, "r")

    for m_id in range(1,2020):
        methodName, machPort, connectionTerminated, connectionInvalidated, hasCompletion = ["", "", 0, 0, 0]
        for line in open(log, "r"):
            if "id " + str(m_id) + ": " not in line:
                continue
            if "MachPort" in line:
                search = re.search('.*MachPort: (.*) Method: (.*)', line)
                machPort = search.group(1)
                methodName = search.group(2)
                continue
            if "Connection Terminated" in line:
                connectionTerminated = 1
                continue
            if "Connection Invalidated" in line:
                connectionInvalidated = 1
                continue
            if "Invocation has a completion handler" in line:
                hasCompletion = 1
                continue
        insert_log(m_id, methodName, machPort, hasCompletion, connectionInvalidated, connectionTerminated)

init()
add_log("results/filemon/run.out")
