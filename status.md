## October, 9th 2018
- Got the new BLE modules HM10 originals.
- Asked my Professor to allow me access to IDEIA lab.

## October, 6th 2018

- The BLE modules I've purchese were not original. Their Firmware was Bolutek's which has fewer instructions (AT commands). I'll keep them for the future, but decided to buy the originals.
- Apparently I can use IDEIA lab if one professor attests for me. Will look into it.
- I'll change my (non-existent) schedule, first will work on the Raspberry Pi, as it has already an embedded Bluetooth chip.
- I need to create a schedulle, today was decided there is only 1 month to do this project.

## October, 4th 2018

- BLE device operates in different modes [[Link]](https://www.eetimes.com/document.asp?doc_id=1278927)

  - Advertising mode
  - Scanning mode
  - master device
  - slave device
- Bought some Bolutek's BLE(CC41-A)

>  In advertising mode, the BLE device periodically transmits advertising information and may respond with more information upon request from other devices.  The scanner device, on the other hand, listens advertising information transmitted by other devices and may request additional information if active scan mode is enabled.  A scanner-only device works in passive mode whereby it only listens for advertising packets. In that case, only receiver functionality is required in the RF part of the design. Similarly, an advertising-only device may just have a transmitter part of the design. It definitely enables additional use cases with cost-sensitive applications. The fact that a stack may be partitioned in sections, which could be excluded if not used in a particular application, is a great opportunity to optimize the stack's size and use the MCU with a smaller FLASH/RAM memory footprint.


## September, 29th 2018

- Arduino has a EEPROM memory (Persistent) [[Link]](https://www.arduino.cc/en/Reference/EEPROM) 
- Sublime Text 3 Arduino IDE Deviot [[Link]](https://github.com/gepd/Deviot)
- PlatformIO IDE [[Link]](https://platformio.org/platformio-ide)


## September, 28th 2018

- Found out I can use [HM-10 BLE](docs/HM-10-as-iBeacon.pdf)
- Bluetooth has commands AT
- Bluetooth Interfacing with HM-10[[Link]](http://fab.cba.mit.edu/classes/863.15/doc/tutorials/programming/bluetooth.html)
- Apple's CoreLocation API [[Link]](https://developer.apple.com/documentation/corelocation/determining_the_proximity_to_an_ibeacon)
- Get help from beacon: AT+HELP?

