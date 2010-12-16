#include <Ethernet.h>
#include <PubSubClient.h>
#include <EthernetDHCP.h>

const int UPDATE_PERIOD_MSEC = 1000;
unsigned long prevMillis;
int photosensorPin = 0;
int fsrPin = 1;
byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte mqttServer[] = { 192, 168, 1, 3 };
char nodeName[] = "sensorArray";
PubSubClient client(mqttServer, 1883, callback);

void callback(char * topic, byte * payload, int length) {
  for(int i = 0; i < length; i++) {
    Serial.print(payload[i]);
  }
  
  Serial.println();
  
}

void setup() {
  Serial.begin(9600);
  /* Block until we acquire an IP address */
  Serial.println("Acquiring IP address");
  EthernetDHCP.begin(mac);

  while(!client.connect(nodeName)) {
    Serial.println("Unable to connect to MQTT broker");
    delay(5000);
  }
  
  prevMillis = 0;
  
}

int photosensorValue = 0;
int fsrValue = 0;
void loop() {
  client.loop();
  EthernetDHCP.maintain();
  
  photosensorValue = analogRead(photosensorPin);
  fsrValue = analogRead(fsrPin);
  
  char buf0[10];
  char buf1[10];
  sprintf(buf0, "%d", photosensorValue);
  sprintf(buf1, "%d", fsrValue);
  
  if(millis() - prevMillis > UPDATE_PERIOD_MSEC) {
    prevMillis = millis();
    
    client.publish("sensorArray/light_level", buf0);
    client.publish("sensorArray/pressure_level", buf1); 
    Serial.print("Publishing photosensor level: ");
    Serial.println(buf0);
    
    Serial.print("Publishing fsr level: ");
    Serial.println(buf1);
  }
}
  
    
