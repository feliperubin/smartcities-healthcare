#!/usr/bin/python3
#
# Author: Felipe Pfeifer Rubin
# Contact: felipe.rubin@acad.pucrs.br
#
# Requirements:
# sudo apt install python3-pip libglib2.0-dev
# sudo pip3 install bluepy

import threading
#import _thread
import os
import sys
import time
#from bluepy.btle import Scanner, DefaultDelegate, Peripheral


# class ScanDelegate(DefaultDelegate):
#     def __init__(self):
#         DefaultDelegate.__init__(self)


#     def HandleDiscovery(self,dev,new_dev,new_dat):
#         if new_dev:
#             pass
#         if new_dat:
#             pass

# scanner = Scanner().withDelegate(ScanDelegate())

HD_UUID = ""
B0_UUID = ""
B1_UUID = ""
B2_UUID = ""
B3_UUID = ""

#acquire(); release()
#threading.Semaphore(0)
mutex_new_data = threading.Lock()

# Responsible for plotting information
# 1. Receives data
# 2. Update the plot image
def plotmanager():
	while 1:
		...
	return 0

# Data Management
# 1. Receives data
# 2. Calculate location
# 3. Send information to plotmanager
def datamanager():
	while 1:
		...
	return 0

# Manages Bluetooth
# 1. Get Beacons and iOS RSSI
# 2. Read iOS characteristic data
# 3. Send information with Data Manager
def bluemanager():
	while 1:
		...
	return 0



def main():
	bm_t = threading.Thread(target=bluemanager, args=())
	dm_t = threading.Thread(target=datamanager, args=())
	pm_t = threading.Thread(target=plotmanager, args=())
	bm_t.start()
	dm_t.start()
	pm_t.start()
	# Keep running 
	while 1:
		cmd_in = input()
		if(cmd_in == "quit"):
			break
		print(cmd_in)
	os._exit(0) # Same as sys.exit(0) but no traceback
	
	
	

if __name__ == "__main__":
    # execute only if run as a script
    main()
