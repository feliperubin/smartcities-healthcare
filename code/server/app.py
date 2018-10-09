
# import bluetooth as bt
# from bluetooth.ble import DiscoveryService
import bluetooth
from bluetooth.ble import DiscoveryService

service = DiscoveryService()

def common_discover():
	devices = bluetooth.discover_devices(lookup_names=True)
	for addr, name in devices:
		print("  %s - %s" % (addr, name))

def ble_discover_services():
	devices = service.discover(2)
	for address, name in devices.items():
		print("name: {}, address: {}".format(name, address))

def __main__():
	# common_discover()
	ble_discover_services()
	return 0

__main__()



