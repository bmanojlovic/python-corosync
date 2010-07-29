#!/usr/bin/python
import libcpg
import select
import errno
import time
from threading import Thread
import pprint


cpg=libcpg.CPG("test.group")
cpg.initialize();
print "initialize"
cpg.join()
print "\nLocal get"
print cpg.local_get()
members = cpg.membership_get()
print "\nCurrent members"
pp = pprint.PrettyPrinter(indent=4)
pp.pprint(members)
def change_printer():
    while True:
        item = cpg.QConfChanged.get()
        print "\nConfiguration changed:"
        pp.pprint (item)
        

cp = Thread(target=change_printer)
cp.setDaemon(True)
cp.start()

def delivery_printer():
    while True:
        item = cpg.QDeliver.get()
        print "\nMessage received:"
        pp.pprint (item)
        

dp = Thread(target=delivery_printer)
dp.setDaemon(True)
dp.start()

def sender():
    while True:
        cpg.mcast_joined("i'm sending this!",2)
        time.sleep (10)

o = Thread(target=sender)
o.setDaemon(True)
o.start()

while not False:
    XX = cpg.fd_get()
    XX = [XX]
    blah = select.select(XX,[],[], 100.0)
    cpg.dispatch(2)
