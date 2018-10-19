/*
* Author: Felipe Pfeifer Rubin
* Contact: felipe.rubin@acad.pucrs.br
*/
#include <SoftwareSerial.h>

#define bname "rbeacon_0"
/*Indoor Positioning*/
#define bchar "0x2AAD"
#define bservice "0x1821"
#define TX_PIN 10
#define RX_PIN 11
SoftwareSerial bSerial(TX_PIN,RX_PIN);

void bSetup() {
  
}
void setup() {
  Serial.begin(9600);
  while(!Serial){} //Wait
  bSerial.begin(9600);
  while(!bSerial){} //Wait
}

void loop() {

  
}
