#include <Ethernet.h>
#include <PubSubClient.h>

byte mac[] = {  0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte ip[] = { 192, 168, 1, 7 };
byte gateway[] = { 192, 168, 1, 1 };
byte subnet[] = { 255, 255, 255, 0 };
byte server[] = { 192, 168, 1, 4 };
int led0 = 3;
int led1 = 4;
PubSubClient client(server, 1883, callback);

void callback(char* topic, byte* payload,int length) {
  // handle message arrived
  
  for(int i = 0; i < length; i++) {
    Serial.print(payload[i]);
  }
  
  Serial.println();
  
  if(length < 2) {
    return;
  }
  
  int pin = -1;
  int value = LOW;
  if(payload[0] == '0') {
    pin = led0;
  } else if(payload[0] == '1') {
    pin = led1;
  }
  
  if(payload[1] == 'u') {
    value = HIGH;
  } else if(payload[1] == 'd') {
    value = LOW;
  }
  
  digitalWrite(pin, value);
}


/*
int main() {
  Serial.begin(9660);
  Ethernet.begin(mac, ip, gateway, subnet);
  if (client.connect("arduino")) {
    client.publish("foo","hello world");
    client.subscribe("bar");
  }
  while(1) {
    client.loop();
    delay(1000);
    client.publish("foo", "test test");
  }
 
  return 0;
}
*/


void setup()
{
  Serial.begin(9660);
  pinMode(led0, OUTPUT);
  pinMode(led1, OUTPUT);
  digitalWrite(led0, LOW);
  digitalWrite(led1, LOW);
  Ethernet.begin(mac, ip, gateway, subnet);
  if (client.connect("blinky")) {
    client.subscribe("blinky/cmd");
  } else {
    Serial.println("Unable to connect to broker");
  }
}

void loop()
{
  client.loop();
}

