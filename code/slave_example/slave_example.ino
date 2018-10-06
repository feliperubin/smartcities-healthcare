#include <SoftwareSerial.h>
 
SoftwareSerial BTSerial(4, 5);
char cmd[32] = {0};
 
void setup() {
   Serial.begin(9600);
   BTSerial.begin(9600);
   BTSerial.write("AT+NAME=Remote\r\n");
   BTSerial.write("AT+TYPE1"); //Simple pairing
}
 
void loop()
{
   static int iter = 0;
   if (BTSerial.available())
   {
       cmd[iter] = BTSerial.read();
 
       //if CRLF (CC41A EOM)
       if((cmd[iter] == 10) && (cmd[iter-1]==13))
       {
   
           Serial.println(cmd);             //dump to serial console
 
           BTSerial.write("Command executed:");
           BTSerial.write(cmd); BTSerial.write("\n");
     } else {
   
     }
   }
   
   if(Serial.available()){
     BTSerial.write(Serial.read());
   }
}
