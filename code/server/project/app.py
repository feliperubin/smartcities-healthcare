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
from bluepy.btle import Scanner, DefaultDelegate, Peripheral

# Matplot lib
import matplotlib.pyplot as plt
import matplotlib.animation as animation
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
	for plot_dev in B_PLOT.keys():
		B_PLOT[plot_dev]['xs'].append(curr_time)
		B_PLOT[plot_dev]['ys'].append(B_RSSI[plot_dev])
		B_PLOT[plot_dev]['xs'] = B_PLOT[plot_dev]['xs'][-100:]
		B_PLOT[plot_dev]['ys'] = B_PLOT[plot_dev]['ys'][-100:]
		values.append(B_PLOT[plot_dev]['xs'])
		values.append(B_PLOT[plot_dev]['ys'])

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
	# ax.plot(xs, ys,x2s,y2s)

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
	# global rssi_test
	# global rssi_test2
	global time_prev
	global B_RSSI
	while 1:
		try:
			devices = scanner.scan(0.35)
			# devices = scanner.scan(0.1)
			for ii in devices:
				# if ii.addr in BX_UUID:
				# if ii.addr == u'59:f9:13:fd:0c:b5':
				# if ii.getValueText(9) in BD_NAMES[1:]:
				dname = ii.getValueText(9)
				if dname in B_RSSI:
					print("Device %s MAC %s, RSSI=%d dB" % (dname,ii.addr,ii.rssi))
					if first_time == 1:
						first_time = 0
						pass
					else:
						time_diff = time.time()-time_prev
					time_prev = time.time()
					# rssi_prev = ii.rssi
					B_RSSI[dname] = ii.rssi
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
