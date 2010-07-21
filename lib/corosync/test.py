#!/usr/bin/python
import libcpg
import select
import errno
import time
from threading import Thread
import pprint


x=libcpg.CPG("test.group")
def messagerec(data):
    print data

def cfgchanged(data):
    print data

x.initialize();
print "initialize"
x.join()
print x.local_get()
x.membership_get()
pp = pprint.PrettyPrinter(indent=4)

def change_printer():
    while True:
        item = x.queue_ch.get()
        pp.pprint (item)
        

cp = Thread(target=change_printer)
cp.setDaemon(True)
cp.start()

def delivery_printer():
    while True:
        item = x.queue_in.get()
        pp.pprint (item)
        

dp = Thread(target=delivery_printer)
dp.setDaemon(True)
dp.start()

def sender():
    while True:
        x.mcast_joined("i'm sending this!")
        time.sleep (10)
        #print "from here item='%s'" % item
        

o = Thread(target=sender)
o.setDaemon(True)
o.start()

while not False:
    XX = x.fd_get()
    XX = [XX]
    blah = select.select(XX,[],[], 100.0)
    x.dispatch(1)

