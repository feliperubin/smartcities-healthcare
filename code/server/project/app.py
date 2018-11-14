#!/usr/bin/python3
#
# Author: Felipe Pfeifer Rubin
# Contact: felipe.rubin@acad.pucrs.br
#
# Requirements:
# sudo apt install python3-pip libglib2.0-dev
# sudo pip3 install bluepy
import numpy as np
import threading
import binascii
#import _thread
import os
import sys
import time
from bluepy.btle import Scanner, DefaultDelegate, Peripheral, UUID

# Matplot lib
# import matplotlib
import matplotlib.pyplot as plt
import matplotlib.animation as animation
import matplotlib.patches as mpatches
# matplotlib.use('TkAgg')
#https://learn.sparkfun.com/tutorials/graph-sensor-data-with-python-and-matplotlib/update-a-graph-in-real-time

class ScanDelegate(DefaultDelegate):
    def __init__(self):
        DefaultDelegate.__init__(self)


    def HandleDiscovery(self,dev,new_dev,new_dat):
        if new_dev:
            pass
        if new_dat:
            pass

scanner = Scanner().withDelegate(ScanDelegate())

# HD_UUID = u''
# B0_UUID = u'00:15:83:40:72:57'
# B1_UUID = u'00:15:83:30:9c:a2'
# B2_UUID = u''
# B3_UUID = u''
# BX_UUID = [B0_UUID,B1_UUID,B2_UUID,B3_UUID]
B_RSSI = {'healthDevice': 0,'RBEACON0':0,'RBEACON1':0,'RBEACON2':0,'RBEACON3':0}
B_PLOT = {'healthDevice': {'xs':[],'ys':[]},'RBEACON0':{'xs':[],'ys':[]},'RBEACON1':{'xs':[],'ys':[]},'RBEACON2':{'xs':[],'ys':[]},'RBEACON3':{'xs':[],'ys':[]}}
hrm_measure = '---'
hrm_char_uuid = UUID(0x2A37)
hrm_service_uuid = UUID(0x180D)
# BD_NAMES = ['healthDevice','RBEACON0','RBEACON1','RBEACON2','RBEACON3']
fig = plt.figure()
ax = fig.add_subplot(1,1,1,)

# xs = []
# ys = []
# x2s = []
# y2s = []
rssi_test = 0
rssi_test2 = 0
time_prev = 0

#acquire(); release()
#threading.Semaphore(0)
mutex_new_data = threading.Lock()
# Responsible for plotting information
# 1. Receives data
# 2. Update the plot image
# def animate(i,xs,ys,x2s,y2s):
def animate(i):
	# global rssi_test
	global B_PLOT
	global B_RSSI
	# global time_prev
	values = []
	curr_time = time.time()
	# line_patch = []
	for plot_dev in B_PLOT.keys():
		B_PLOT[plot_dev]['xs'].append(curr_time)
		B_PLOT[plot_dev]['ys'].append(B_RSSI[plot_dev])
		B_PLOT[plot_dev]['xs'] = B_PLOT[plot_dev]['xs'][-100:]
		B_PLOT[plot_dev]['ys'] = B_PLOT[plot_dev]['ys'][-100:]
		values.append(B_PLOT[plot_dev]['xs'])
		values.append(B_PLOT[plot_dev]['ys'])
		print("plotdev = ",plot_dev)
		# line_patch.append(mpatches.Patch(label=plot_dev))

	

	# B_PLOT['healthDevice']['xs'].append(time_prev)
	# B_PLOT['healthDevice']['ys'].append(B_RSSI['healthDevice'])
	# values.append(B_PLOT['healthDevice']['xs'])
	# values.append(B_PLOT['healthDevice']['ys'])
	# xs.append(time_prev)
	# ys.append(rssi_test)
	# x2s.append(time_prev)
	# y2s.append(rssi_test2)


	# Limit x and y lists to 20 items

	# xs = xs[-100:]
	# ys = ys[-100:]
	# x2s = x2s[-100:]
	# y2s = y2s[-100:]

	# Draw x and y lists
	ax.clear()
	# ax.plot((x,y) for x in B_PLOT.values())
	ax.plot(*values)
	# hrm_patch = mpatches.Patch(label='Heart Rate: '+hrm_measure)

	# ax.legend(handles=line_patch)
	

	# Format plot
	plt.xticks(rotation=45, ha='right')
	axes = plt.gca()
	# axes.set_ylim([-100,100])
	plt.subplots_adjust(bottom=0.30)
	plt.title('Bluetooth over Time')
	plt.ylabel('RSSI')

def plotmanager():
	print("PlotManager Started")
	

    # Add x and y to lists
    # xs.append(dt.datetime.now().strftime('%H:%M:%S.%f'))
    # while 1:
    	# animate()
	# ani = animation.FuncAnimation(fig, animate, fargs=(xs, ys), interval=1000)
	# plt.show()

	
	# ani = animation.FuncAnimation(fig, animate, fargs=(xs, ys), interval=1000)
	# plt.show()

	# while 1:
		# ...
	# return 0

# Data Management
# 1. Receives data
# 2. Calculate location
# 3. Send information to plotmanager
def datamanager():
	print("DataManager Started")
	while 1:
		...
	return 0

# Manages Bluetooth
# 1. Get Beacons and iOS RSSI
# 2. Read iOS characteristic data
# 3. Send information with Data Manager
def bluemanager():
	print("BlueManager Started")
	time_diff = 0
	first_time = 1
	pconn = Peripheral()
	# global rssi_test
	# global rssi_test2
	global time_prev
	global B_RSSI
	global hrm_measure
	while 1:
		try:
			devices = scanner.scan(0.35)
			# devices = scanner.scan(0.1)
			for ii in devices:
				# p = Peripheral(ii.addr)
				# p.getServices()
				# if ii.addr in BX_UUID:
				# if ii.addr == u'59:f9:13:fd:0c:b5':
				# if ii.getValueText(9) in BD_NAMES[1:]:
				dname = ii.getValueText(9)
				if dname in B_RSSI:
					# print("Device %s MAC %s, RSSI=%d dB" % (dname,ii.addr,ii.rssi))
					if first_time == 1:
						first_time = 0
						pass
					else:
						time_diff = time.time()-time_prev
					time_prev = time.time()
					# rssi_prev = ii.rssi
					B_RSSI[dname] = ii.rssi
					print("B_RSSI[",dname,"] = ",ii.rssi)
					if dname == "healthDevice":
						# print("ok")
						pconn.connect(ii.addr,"random")
						# print("connected ?")
						# hrm_char = pconn.getCharacteristics(startHnd=57, endHnd=60, uuid=None)
						# hrm_service = pconn.getServiceByUUID()
						# Handle   UUID                                Properties
						# -------------------------------------------------------
						# Characteristic <Device Name>   0x03   00002a00-0000-1000-8000-00805f9b34fb READ 
						# Characteristic <Appearance>   0x05   00002a01-0000-1000-8000-00805f9b34fb READ 
						# Characteristic <Service Changed>   0x08   00002a05-0000-1000-8000-00805f9b34fb INDICATE 
						# Characteristic <8667556c-9a37-4c91-84ed-54ee27d90049>   0x0C   8667556c-9a37-4c91-84ed-54ee27d90049 NOTIFY WRITE EXTENDED PROPERTIES 
						# Characteristic <af0badb1-5b99-43cd-917a-a77bc549e3cc>   0x11   af0badb1-5b99-43cd-917a-a77bc549e3cc NOTIFY WRITE EXTENDED PROPERTIES 
						# Characteristic <Battery Level>   0x16   00002a19-0000-1000-8000-00805f9b34fb NOTIFY READ 
						# Characteristic <Current Time>   0x1A   00002a2b-0000-1000-8000-00805f9b34fb NOTIFY READ 
						# Characteristic <Local Time Information>   0x1D   00002a0f-0000-1000-8000-00805f9b34fb READ 
						# Characteristic <Manufacturer Name String>   0x20   00002a29-0000-1000-8000-00805f9b34fb READ 
						# Characteristic <Model Number String>   0x22   00002a24-0000-1000-8000-00805f9b34fb READ 
						# Characteristic <69d1d8f3-45e1-49a8-9821-9bbdfdaad9d9>   0x25   69d1d8f3-45e1-49a8-9821-9bbdfdaad9d9 WRITE EXTENDED PROPERTIES 
						# Characteristic <9fbf120d-6301-42d9-8c58-25e699a21dbd>   0x28   9fbf120d-6301-42d9-8c58-25e699a21dbd NOTIFY 
						# Characteristic <22eac6e9-24d6-4bb5-be44-b36ace7c7bfb>   0x2B   22eac6e9-24d6-4bb5-be44-b36ace7c7bfb NOTIFY 
						# Characteristic <9b3c81d8-57b1-4a8a-b8df-0e56f7ca51c2>   0x2F   9b3c81d8-57b1-4a8a-b8df-0e56f7ca51c2 NOTIFY WRITE EXTENDED PROPERTIES 
						# Characteristic <2f7cabce-808d-411f-9a0c-bb92ba96c102>   0x33   2f7cabce-808d-411f-9a0c-bb92ba96c102 NOTIFY WRITE EXTENDED PROPERTIES 
						# Characteristic <c6b2f38c-23ab-46d8-a6ab-a3a870bbd5d7>   0x37   c6b2f38c-23ab-46d8-a6ab-a3a870bbd5d7 READ WRITE EXTENDED PROPERTIES 
						# Characteristic <Heart Rate Measurement>   0x3B   00002a37-0000-1000-8000-00805f9b34fb NOTIFY READ 
						# Characteristic <Location Name>   0x3F   00002ab5-0000-1000-8000-00805f9b34fb NOTIFY READ 
						# Characteristic <Location Name>   0x42   00002ab5-0000-1000-8000-00805f9b34fb NOTIFY READ 
						# Characteristic <Location Name>   0x45   00002ab5-0000-1000-8000-00805f9b34fb NOTIFY READ 
						# Characteristic <Location Name>   0x48   00002ab5-0000-1000-8000-00805f9b34fb NOTIFY READ 
						# Characteristic <Location Name>   0x4B   00002ab5-0000-1000-8000-00805f9b34fb NOTIFY READ 
						
						# hrm_service_uuid = UUID(0x003B)
						# hrm_service = pconn.getServiceByUUID(hrm_service_uuid)
						# ch = hrm_service.getCharacteristics(button_char_uuid)[0]
						# print(hrm_service)
						hrm_service = pconn.getServiceByUUID(hrm_service_uuid)
						try:
							hrm_char = hrm_service.getCharacteristics(hrm_char_uuid)[0]
							if (hrm_char.supportsRead()):
								# This is how to decode
								hrm_measure = hrm_char.read().decode('utf-8')
								# hrm_measure = int(hrm_value)

									
						finally:
							pconn.disconnect()
						# chList = pconn.getCharacteristics()
						# print ("Handle   UUID                                Properties")
						# print ("-------------------------------------------------------")                      
						# for ch in chList:
						#    print (ch,"  0x"+ format(ch.getHandle(),'02X')  +"   "+str(ch.uuid) +" " + ch.propertiesToString())

						# print(hrm_char[0],": ",hrm_char.propertiesToString())
						# for s in pconn.getServices():
							# print("Service: ",s)
						# pconn.disconnect()
					# rssi_test = ii.rssi
				# if ii.getValueText(9) == BD_NAMES[0]:
					# rssi_test2 = ii.rssi
					continue
		except Exception as exc:
			print("Error ",exc)
			continue
	return 0


# This is the plotManager()
def main():
	bm_t = threading.Thread(target=bluemanager, args=())
	dm_t = threading.Thread(target=datamanager, args=())
	# pm_t = threading.Thread(target=plotmanager, args=())
	bm_t.start()
	dm_t.start()
	# pm_t.start()
	# Keep running
	# global rssi_test
	# ani = animation.FuncAnimation(fig, animate, fargs=(xs, ys,x2s,y2s), interval=1000)
	# ani = animation.FuncAnimation(fig, animate, fargs=(xs, ys,x2s,y2s), interval=250)
	ani = animation.FuncAnimation(fig, animate, fargs=(), interval=250)
	plt.show() 
	while 1:
		cmd_in = input()
		if(cmd_in == "quit" or cmd_in == "q"):
			break
		print(cmd_in)
	os._exit(0) # Same as sys.exit(0) but no traceback
	
	
	

if __name__ == "__main__":
    # execute only if run as a script
    main()
