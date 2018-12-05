#!/bin/python

#curl -v -X POST -d "{\"temperature\": 25}"
#localhost:9090/api/v1/9jmb70LAdydySSHQWzRi/telemetry --header 
#"Content-Type:application/json"

import os
import time
import sys
import paho.mqtt.client as mqtt
import json
import socket
import threading
import pandas as pd
import numpy as np
import binascii
from knn import knn
THINGSBOARD_HOST = 'localhost'
ACCESS_TOKEN = 'eFJ4v4tXfXQsKPd1e1Wb'
# ACCESS_TOKEN = 'eL9O2GQWNr2B7p0wBXVP'
THINGSBOARD_USERNAME = 'tenant@thingsboard.org'
THINGSBOARD_PASSWORD = 'tenant'
THINGSBOARD_IP = 1883


# Socket Server
#https://gist.github.com/Integralist/3f004c3594bbf8431c15ed6db15809ae
bind_ip = '0.0.0.0' # IP addresses allowed
bind_port = 9999 # Port to connet
max_conn = 999 # Maximum Backlog Connection

server = socket.socket(socket.AF_INET,socket.SOCK_STREAM) # The Server
server.bind((bind_ip,bind_port)) # Bind server configuration
server.listen(max_conn) # How many backlog connections allowed
#
# To kill process at port X:
# Check Process running on port 9999
# MacOS
# sudo lsof -i tcp:9999
# Then sudo kill -9 
# Ubuntu:
# netstat -vanp tcp | grep 9999

B_COLUMNS = np.array(['RBEACON0','RBEACON1','RBEACON2','RBEACON3','Class'])
df = pd.DataFrame(columns=B_COLUMNS)

# # Data capture and upload interval in seconds. Less interval will eventually hang the DHT22.
# INTERVAL=2

# sensor_data = {'temperature': 0, 'humidity': 0}

# next_reading = time.time() 

client = mqtt.Client()

# # Set access token
client.username_pw_set(ACCESS_TOKEN)

# # Connect to ThingsBoard using default MQTT port and 60 seconds keepalive interval
client.connect(THINGSBOARD_HOST, THINGSBOARD_IP, 180)

client.loop_start()
# client.loop_forever()
# try:
#     while True:
#         humidity = 10
#         temperature = 20
#         print(u"Temperature: {:g}\u00b0C, Humidity: {:g}%".format(temperature, humidity))
#         sensor_data['temperature'] = temperature
#         sensor_data['humidity'] = humidity

#         # Sending humidity and temperature data to ThingsBoard
#         client.publish('v1/devices/me/telemetry', json.dumps(sensor_data), 1)

#         next_reading += INTERVAL
#         sleep_time = next_reading-time.time()
#         if sleep_time > 0:
#             time.sleep(sleep_time)
# except KeyboardInterrupt:
#     pass

# client.loop_stop()
# client.disconnect()




#
# Pass an information to a server
#
# devices
# learn
# train
# track
#hrm
userdata = {}
def telemetryServer(sendlocation=0):
	global client
	send_info = {}
	# send_info['hrm'] = userdata['hrm']
	send_info['heartrate'] = userdata['hrm']
	if sendlocation:
		send_info['location'] = track_position()
		print('Acquired Position = ',send_info['location'])
	# client.publish('v1/devices/me/telemetry',json.dumps(send_info),1)
	# client.publish('v1/devices/me/heartrate',json.dumps(send_info),1)
	#client.publish('v1/devices/HRM/heartrate',json.dumps(send_info),1)
	client.publish('v1/devices/me/attributes',json.dumps(send_info),1)
	# IF it's set to track then:
	# if userdata['track']:




	# client.publish('v1/devices/me/attributes',json.dumps(send_info),1)
	return 0
 
classifier = knn()
def train():
	if df.shape[0] == 0:
		print('No data to Train!')
		return 0
	# Grab all but last row == beacons
	classifier.X = df.iloc[:,:-1].values.tolist()
	# Grab last row == class
	classifier.Y = df.iloc[:,df.shape[1]-1].values
	classifier.train()
	print('Trained')
	return 1

def track_position():
	print('Track Position')
	if classifier.has_trained:
		print('Already Trained')
		return classifier.predict(np.fromiter(userdata['devices'].values(), dtype=int)[np.newaxis,:])[0]
	else:
		return "unknown"
# Verifies if it's a possible Heart Attack 
def heartattack(bpm):
	if bpm > 140:
		# print("Possible Heart Attack!")
		return 1
	else:
		return 0


# Get an available csv name 
def available_csvname():
	csvindex = 0
	while os.path.exists("data"+str(csvindex)+".csv"):
		csvindex+=1
	return data+str(csvindex)+".csv"
# Wants to learn
def wants_learn():
	print('Wants Learn')
	i = df.shape[0]
	jlast = len(userdata['devices'].keys())
	for j in userdata['devices'].keys():
		df.loc[i,j] = userdata['devices'][j]
	df.loc[i,'Class'] = userdata['learn']
	return 1

# This handles a client connection
# hrm: Integer Heart Beat
# knn: Integer Number of Neighbors 
# learn: None or 'Location'
# train: True or False
# track: True or False
# devices = {'X': 1 , 'Y': 321}
def handle_client_connection(client_socket):
	global userdata
	request = client_socket.recv(1024)
	out = request.decode('utf-8')
	#print("DECODED: ",out)
	userdata = json.loads(out)
	client_socket.send('ACK!'.encode())
	client_socket.close()

	classifier.neighbors = userdata['knn']
	if userdata['train']:
		train()

	if heartattack(userdata['hrm']) and userdata['track']:
		telemetryServer(sendlocation=1)
	else:
		telemetryServer(sendlocation=0)		
	
	# If it wants to learn:
	if userdata['learn'] is not None:
		wants_learn()



def main():
	while True:
	    client_sock, address = server.accept()
	    #print('Accepted connection from {}:{}'.format(address[0], address[1]))
	    client_handler = threading.Thread(
	        target=handle_client_connection,
	        args=(client_sock,)  # without comma you'd get a... TypeError: handle_client_connection() argument after * must be a sequence, not _socketobject
	    )
	    client_handler.start()



if __name__ == "__main__":
	main()



