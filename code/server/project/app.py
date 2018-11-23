##!/usr/bin/python3
#
# Author: Felipe Pfeifer Rubin
# Contact: felipe.rubin@acad.pucrs.br
#
# Requirements:
# sudo apt install python3-pip libglib2.0-dev
# sudo pip3 install bluepy
# sudo pip3 install scikit-learn
# Run this:
# sudo su
# chmod +x app.py
# ./app.py
# Set dicoverable: sudo hciconfig hci0 noscan (NOT WORKING WHILE SCANNING)
# pip install setuptools
# pip install -U scikit-learn
# sudo apt-get install libblas-dev 
# sudo apt-get install python3-pandas
# sudo apt-get install libatlas-base-dev
import pandas as pd  
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
from matplotlib.offsetbox import AnchoredText
from knn import knn
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


#Scanned by RCENTRAL
B_TABLE = {'RBEACON0':0,'RBEACON1':0,'RBEACON2':0,'RBEACON3':0,'science': 0} 
B_RSSI = {'healthDevice': 0,'RBEACON0':0,'RBEACON1':0,'RBEACON2':0,'RBEACON3':0}
B_PLOT = {'healthDevice': {'xs':[],'ys':[],'color':'b'},'RBEACON0':{'xs':[],'ys':[],'color':'g'},'RBEACON1':{'xs':[],'ys':[],'color':'r'},'RBEACON2':{'xs':[],'ys':[],'color':'c'},'RBEACON3':{'xs':[],'ys':[],'color':'m'}}
B_COLUMNS = ['RBEACON0','RBEACON1','RBEACON2','RBEACON3','science','Class']
#
# Class 	| CHAR(RBEACON0) | CHAR(RBEACON1) | CHAR(RBEACON2) | CHAR(RBEACON3)
# RBEACON0	| RSSI			 |	RSSI		  |	RSSI		   | RSSI
# RBEACON1	| RSSI			 |	RSSI		  |	RSSI		   | RSSI
#

# knn_table = np.array(list(B_TABLE.keys()))


train_size = 0
# knn_table = numpy.(shape(,6))

knn_table = pd.DataFrame(columns=B_COLUMNS)
# knn_table = pd.Series()
# knn_table = np.dot(knn_table,knn_table.T)
# knn_table = np.array([B_TABLE.keys().values,len(B_TABLE.keys())])
# print(knn_table)

#
# The Characteristics and services used
# The service is Heart Rate Monitor
# For the Characteristics there are the standard Heart Rate and Nbeacons Locations Characteristics
#
hrm_measure = '---'
hrm_char_uuid = UUID(0x2A37) # Heart Rate Characteristic
hrm_service_uuid = UUID(0x180D) # Heart Rate Monitor Service
location_char_uuid = UUID(0x2A69) # Location Characteristic
training_char_uuid = UUID(0x2AAD) # Training Characteristic

fig = plt.figure()
ax = fig.add_subplot(1,1,1,)
hrm_label = plt.gcf().text(0.2, 0.15, "Heart Rate:  "+hrm_measure, fontsize=14)
# ax2 = fig.add_subplot(2,2,2,)


time_prev = 0

#acquire(); release()
# threading.Semaphore(0)
mutex_access_table = threading.Lock()
# Responsible for plotting information
# 1. Receives data
# 2. Update the plot image
# def animate(i,xs,ys,x2s,y2s):
def animate(i):
	# global rssi_test
	global B_PLOT
	global B_RSSI
	global B_TABLE
	global time_prev
	global hrm_label
	values = []
	curr_time = time.time()
	# line_patch = []
	ax.clear()
	for plot_dev in B_PLOT.keys():
		B_PLOT[plot_dev]['xs'].append(curr_time)
		B_PLOT[plot_dev]['ys'].append(B_RSSI[plot_dev])
		B_PLOT[plot_dev]['xs'] = B_PLOT[plot_dev]['xs'][-100:]
		B_PLOT[plot_dev]['ys'] = B_PLOT[plot_dev]['ys'][-100:]
		# values.append(B_PLOT[plot_dev]['xs'])
		# values.append(B_PLOT[plot_dev]['ys'])
		# values.append(color="blue")
		ax.plot(B_PLOT[plot_dev]['xs'],B_PLOT[plot_dev]['ys'],B_PLOT[plot_dev]['color'],label=plot_dev)
		# ax2.plot(B_PLOT[plot_dev]['xs'],B_PLOT[plot_dev]['ys'],B_PLOT[plot_dev]['color'],label=plot_dev)
		# line_patch.append(mpatches.Patch(label=plot_dev))

	# Limit x and y lists to 20 items
	# Draw x and y lists
	# ax.clear()
	# ax.plot((x,y) for x in B_PLOT.values())
	# ax.plot(*values)

	# hrm_patch = mpatches.Patch(label='Heart Rate: '+hrm_measure)

	# ax.legend(handles=line_patch)
	ax.legend()
	# ax.text(0.02, 0.5, "SOMETHINGSOMETHING", fontsize=14)
	hrm_label.set_text("Heart Rate:  "+hrm_measure)
	


	# ax.text(0.05,0.95,hrm_measure)

	# Format plot
	plt.xticks(rotation=45, ha='right')
	axes = plt.gca()
	# axes.set_ylim([-100,100])
	plt.subplots_adjust(bottom=0.30)
	plt.title('Bluetooth over Time')
	plt.ylabel('RSSI')


# Manages Bluetooth
# 1. Get Beacons and iOS RSSI
# 2. Read iOS characteristic data
def bluemanager():
	print("BlueManager Started")
	time_diff = 0
	first_time = 1
	pconn = Peripheral()
	global time_prev
	global B_RSSI
	global B_TABLE
	global hrm_measure
	global knn_table
	while 1:
		try:
			devices = scanner.scan(0.35) # Scans devices
			# devices = scanner.scan(0.1)
			for ii in devices: #For each device
				dname = ii.getValueText(9)
				if dname in B_RSSI:
					if verbose:
						print("\rDevice %s MAC %s, RSSI=%d dB" % (dname,ii.addr,ii.rssi))
					if first_time == 1:
						first_time = 0
						pass
					else:
						time_diff = time.time()-time_prev
					time_prev = time.time()
					# rssi_prev = ii.rssi
					B_RSSI[dname] = ii.rssi
					#print("B_RSSI[",dname,"] = ",ii.rssi)
					if dname == "healthDevice": # To read the B_TABLE
						
						pconn.connect(ii.addr,"random") #Connect to it, Addr type is RANDOM
						try:
							hrm_service = pconn.getServiceByUUID(hrm_service_uuid)
							hrm_measure = hrm_service.getCharacteristics(hrm_char_uuid)[0].read().decode('utf-8')
							training_state = int(hrm_service.getCharacteristics(training_char_uuid)[0].read().decode('utf-8'))
							
							training_row = np.zeros(len(B_COLUMNS))
							training_row[len(B_COLUMNS)-1] = training_state
							cont = 0
							nshape = knn_table.shape[0]
								

							for location_char in hrm_service.getCharacteristics(location_char_uuid):
								dev_name,dev_rssi = location_char.read().decode('utf-8').split(';')
								#print(dev_name,": ",dev_rssi)
								B_TABLE[dev_name] = dev_rssi
								training_row[cont] = dev_rssi
								cont+=1
							if training_state > -1:
								knn_table.loc[nshape] = training_row
							elif classifier.has_trained:
								# print('Test: ',training_row[:,-1])
								# print(training_row[:-1])
								print('Prediction: ',classifier.predict(training_row[:-1][np.newaxis,:]))

						finally:
							pconn.disconnect()
					continue
		except Exception as exc:
			print("Error ",exc)
			continue
	return 0


classifier = knn()
verbose = False
def field_study():
	if knn_table.shape[0] == 0:
		print('No data to train!')
		return


	# classifier.X = knn_table.iloc[:,:-1].values
	# classifier.X = knn_table.iloc[:,:-1].values.tolist()
	classifier.X = knn_table.iloc[:,:-1].values.tolist()
	classifier.Y = knn_table.iloc[:,knn_table.shape[1]-1].values
	
	# print("X SHAPE IS ",classifier.X.shape)
	# print("Y SHAPE IS ",classifier.Y.shape)
	print('Classifier X: ',classifier.X)
	print('Classifier Y: ',classifier.Y)
	classifier.train()
	print('Ok')

	# classifier.Y = knn_table.
	# print(knn_table.iloc[:,:-1])
	return 0

#
#TO DO COMMANDS:
# Save to CSV
# LOAD FROM CSV
# CLEAR TABLE
# 
# NOTE: NEED TO CREATE A MUTEX TO CHANGE THE KNN_TABLE HERE
def climanager():
	global verbose
	global knn_table
	print('CLIManager Started')
	cmd_in = ""
	while 1:
		cmd_in = input()
		if cmd_in == "quit" or cmd_in == "q":
			os._exit(0) # Same as sys.exit(0) but no traceback
		elif cmd_in == "train":
			field_study()
		elif cmd_in == "table":
			print(knn_table)
		elif cmd_in == "verbose":
			verbose = not verbose
		else:
			print("Command not known")
		# print(cmd_in)
	
	return 0
# This is the plotManager()
def main():
	print('Initializing Components...')
	bm_t = threading.Thread(target=bluemanager, args=())
	cl_t = threading.Thread(target=climanager,args=())
	print('Starting BlueManager...')
	bm_t.start()
	print('Starting CLIManager...')
	cl_t.start()
	print('Ready')
	
	# Keep running
	# ani = animation.FuncAnimation(fig, animate, fargs=(), interval=250)
	# plt.show() 
	

if __name__ == "__main__":
    # execute only if run as a script
    main()
