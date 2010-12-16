#include <Ethernet.h>
#include <PubSubClient.h>
#include <EthernetDHCP.h>

const int updatePeriod = 1000;
unsigned long prevMillis;
int bluePin = 6;
int redPin = 3;
byte mac[] = { 0xCA, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte mqttServer[] = { 192, 168, 1, 4 };
char nodeName[] = "blinky";
PubSubClient client(mqttServer, 1883, callback);

void callback(char * topic, byte * payload, int length) {
  char buf[10];
  for(int i = 0; (i < length) && (i < 10); i++) {
    buf[i] = payload[i];
  }
  
  if(!strcmp(topic, "sensorArray/light_level")) {
    analogWrite(bluePin, map(atoi(buf), 0, 1024, 0, 255));
    Serial.print("Light level: ");
  } else if(!strcmp(topic, "sensorArray/pressure_level")) {
    analogWrite(redPin, map(atoi(buf), 0, 1024, 0, 255));
    Serial.print("Pressure level: ");
  }
  Serial.println(atoi(buf));
  
}

void setup() {
  Serial.begin(9600);
  /* Block until we acquire an IP address */
  EthernetDHCP.begin(mac);

  while(!client.connect(nodeName)) {
    Serial.println("Unable to connect to MQTT broker");
    delay(5000);
  }
  
  client.subscribe("sensorArray/#");
}

void loop() {
  client.loop();
  EthernetDHCP.maintain();
}
