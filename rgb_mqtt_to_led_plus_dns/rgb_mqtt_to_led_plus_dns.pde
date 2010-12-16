#include <Ethernet.h>
#include <PubSubClient.h>
#include <EthernetDHCP.h>
#include <EthernetDNS.h>

const int updatePeriod = 1000;
unsigned long prevMillis;
int bluePin = 6;
int redPin = 3;
int greenPin = 5;
byte mac[] = { 0xCA, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte mqttServer[] = { 192, 168, 1, 4 };
char brokerName[] = "realtime.ngi.ibm.com";
char nodeName[] = "blinky";
PubSubClient *client;

void callback(char * topic, byte * payload, int length) {
  char buf[10];
  for(int i = 0; (i < length) && (i < 10); i++) {
    buf[i] = payload[i];
  }
  
  if(!strcmp(topic, "blinky/blue")) {
    analogWrite(bluePin, map(atoi(buf), 0, 1024, 0, 255));
    Serial.print("Blue level: ");
  } else if(!strcmp(topic, "blinky/red")) {
    analogWrite(redPin, map(atoi(buf), 0, 1024, 0, 255));
    Serial.print("Red level: ");
  } else if(!strcmp(topic, "blinky/green")) {
    analogWrite(greenPin, map(atoi(buf), 0, 1024, 0, 255));
    Serial.print("Green level: ");
  }
  Serial.println(atoi(buf));
  
}

void setup() {
  Serial.begin(9600);
  /* Block until we acquire an IP address */
  Serial.println("Acquiring IP address");
  EthernetDHCP.begin(mac);
  Serial.println("IP address acquired");
  Serial.print("IP address: ");
  Serial.println(ip_to_str(EthernetDHCP.ipAddress()));
  Serial.print("Gateway address: ");
  Serial.println(ip_to_str(EthernetDHCP.gatewayIpAddress()));
  Serial.print("DNS address: ");
  Serial.println(ip_to_str(EthernetDHCP.dnsIpAddress()));
  
  EthernetDNS.setDNSServer(EthernetDHCP.dnsIpAddress());

  /* Resolve the IP address of ibm's mqtt broker */
  Serial.print("Resolving IP address of ");
  Serial.println(brokerName);
  
  byte brokerip[4];
  DNSError err = 
    EthernetDNS.resolveHostName(brokerName, brokerip);
  
  if(err == DNSSuccess) {
    Serial.println("IP address resolved");
    Serial.print("IP address: ");
    Serial.println(ip_to_str(brokerip));
  } else if(err == DNSTimedOut) {
    Serial.println("DNS timed out");
  } else if(err == DNSNotFound) {
    Serial.println("Host name not found");
  } else {
    Serial.println("Other error");
    Serial.println((int) err, DEC);
  }
  
  client = (PubSubClient*) malloc(sizeof(PubSubClient));
  *client = PubSubClient(brokerip, 1883, callback);
  
  while(!client->connect(nodeName)) {
    Serial.println("Unable to connect to MQTT broker");
    delay(5000);
  }
  
  client->subscribe("blinky/#");
}

void loop() {
  client->loop();
  EthernetDHCP.maintain();
}

const char* ip_to_str(const uint8_t* ipAddr)
{
  static char buf[16];
  sprintf(buf, "%d.%d.%d.%d\0", ipAddr[0], ipAddr[1], ipAddr[2], ipAddr[3]);
  return buf;
}
