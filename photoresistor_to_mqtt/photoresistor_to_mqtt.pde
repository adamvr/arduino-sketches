#include <Ethernet.h>
#include <PubSubClient.h>
#include <EthernetDHCP.h>

const int UPDATE_PERIOD_MSEC = 1000;
unsigned long prevMillis;
int analogPin = 0;
byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte mqttServer[] = { 192, 168, 1, 4 };
char nodeName[] = "photosensor";
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
  EthernetDHCP.begin(mac);

  while(!client.connect(nodeName)) {
    Serial.println("Unable to connect to MQTT broker");
    delay(5000);
  }
  
  prevMillis = 0;
  
}

void loop() {
  client.loop();
  EthernetDHCP.maintain();
  
  int analogValue = analogRead(analogPin);
  
  char buf[10];
  sprintf(buf, "%d", analogValue);
  
  if(millis() - prevMillis > UPDATE_PERIOD_MSEC) {
    prevMillis = millis();
    
    client.publish("photosensor/level", buf);
    Serial.print("Publishing photosensor level: ");
    Serial.println(buf);
  }
  
  
}
  
    
