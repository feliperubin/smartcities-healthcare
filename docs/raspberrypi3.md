# Installation



Install Bluetooth requirements with python support

```bash
sudo apt install python-pip python-bluez libbluetooth-dev libboost-python-dev libboost-thread-dev libglib2.0-dev bluez bluez-hcidump
```



Install Python Flask

```python
sudo apt install python3-pip
pip install --upgrade pip
pip install flask
pip install gattlib
```



Install Python bluez


```python
#Anaconda 3.4
conda install -c ericmjl pybluez 
#Linux Python 3
pip3 install pybluez
pip3 install pybluez[ble]
pip3 install pygattlib
```

Build from source gattlib

```bash
sudo apt install mercurial
hg clone https://bitbucket.org/OscarAcena/pygattlib
cd pygattlib
sudo python3 setup.py install
```



## Bluez

Start

```bash
sudo systemctl start bluetooth #Start bluez
sudo systemctl status bluetooth #Status
sudo systemctl stop bluetooth  #Stop
```

Edit to enable experimental features, then restart the service
```bash
sudo nano /lib/systemd/system/bluetooth.service 
```

## Bluetooth CLI

```bash
bluetoothctl
```

