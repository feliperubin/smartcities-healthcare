#!/usr/bin/python3

import time
from bluepy.btle import Scanner, DefaultDelegate

class ScanDelegate(DefaultDelegate):
    def __init__(self):
        DefaultDelegate.__init__(self)


    def HandleDiscovery(self,dev,new_dev,new_dat):
        if new_dev:
            pass
        if new_dat:
            pass
        
scanner = Scanner().withDelegate(ScanDelegate())

time_diff = 0
first_time = 1
while 1:
    try:
        devices = scanner.scan(0.35)
##        print("Amount of Devices = "+str(len(devices)))
        for ii in devices:
##            print(ii.addr)
            if ii.addr == u'00:15:87:00:4e:d4' or ii.addr == u'00:15:83:10:d5:39' \
               or ii.addr == '20:ab:37:87:03:36' or ii.addr=='d4:36:39:9d:9c:5e' \
               or ii.addr== u'd4:36:39:dc:11:47':

                print("Device %s, RSSI=%d dB" % (ii.addr,ii.rssi))
                if first_time == 1:
                    first_time = 0
                    pass
                else:
                    time_diff = time.time()-time_prev
                    

                
                time_prev = time.time()
                rssi_prev = ii.rssi
                continue

    except:
        continue

