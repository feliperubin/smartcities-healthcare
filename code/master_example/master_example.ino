#include <SoftwareSerial.h>
 
SoftwareSerial BTSerial(4, 5);
 
void setup() {
   Serial.begin(9600);
   BTSerial.begin(9600);
   BTSerial.write("AT+DEFAULT\r\n");
   BTSerial.write("AT+RESET\r\n");
   BTSerial.write("AT+NAME=Controller\r\n");
   BTSerial.write("AT+ROLE1\r\n");
   BTSerial.write("AT+TYPE1"); //Simple pairing
}
 
void loop()
{
   if (BTSerial.available())
       Serial.write(BTSerial.read());
   if (Serial.available())
       BTSerial.write(Serial.read());
}
