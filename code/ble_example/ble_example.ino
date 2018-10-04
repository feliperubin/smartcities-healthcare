#include <SoftwareSerial.h>

//Bluetooth Serial
SoftwareSerial bSerial(8,7); //TX,RX 

/*
  Serial.write(x): Send a byte with the value x
  int len
*/
const int wait_time = 10;
void bexec(String command){
  bSerial.println(command);
  bwait();
}
void bwait(){
  int late = 0;
  char c;
  while(true){
    if(bSerial.available()){
      c = bSerial.read();
      Serial.print(c);
      late = 0;
    }else{
      if(late){
        return;    
      }
      delay(wait_time);
      late = 1;
    }
  }
}
void setup() {
  //Open Serial communications and wait for port to open:
  Serial.begin(9600);
  while(!Serial){}//Wait Serial port to Connect. Needed for native USB port only
  
  bSerial.begin(9600);
  bexec("AT");
//  bexec("AT+HELP");
//  bexec("AT+RENEW");
//  bexec("AT+RESET");
    //bexec("AT+STATE"); //Wait to Start
  //bexec("AT+MARJ0x1234");
  //bexec("AT+MIN00xFA01");
//  bexec("AT+ADVI5");
//  bexec("AT+NAMERBEACON"); //Set The name
  //bexec("AT+NAME");
//  bexec("AT+DEFAULT");
//  bexec("AT+DELO2");
//  bexec("AT+PWRM0");
//  bexec("AT+RESET");
//bexec("AT+START");
//  bexec("AT+IBE2");
//bexec("AT+INQ");
//bexec("AT+NAME");
//bexec("AT+NOT");
//bexec("AT+ROLE1");
//bexec("AT+ROLE0");
//bexec("AT+NOTI1");
//bexec("AT+NAMEFELIPEBLUE");
Serial.println("\nBluetooth SETUP COMPLETED");
  
}
String inbuff;
int recv = 0;
void loop() {

////  if(Serial.available()){
////    Serial.write(Serial.read());
////  }
//  if(Serial.available()){
//      int rbuff = Serial.read();
//      if(rbuff == 10){
//        recv = 1;
//        
//      } //Received Command;
////      inbuff+= char(Serial.read());
////      Serial.println(Serial.read());
//      inbuff+=char(rbuff);
////    Serial.println(inbuf)
//    //Serial.write(Serial.read());
//  }else{
//    if(recv == 1){
////      Serial.println("Inbuff: "+inbuff);
//      bexec(inbuff);
//      inbuff="";
//      recv = 0;
//    }
//  }

  
  if(bSerial.available()){
    Serial.write(bSerial.read());
  }else if(Serial.available()){
    bSerial.write(Serial.read());
  }
}
