#include <Ethernet.h>
#include <PubSubClient.h>
#include <EthernetDNS.h>
#include <EthernetDHCP.h>

const int UPDATE_PERIOD_MSEC = 5000;
unsigned long prevMillis;
int randomPin = 0;
byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0x5E, 0xED };
byte mqttServer[] = { 192, 168, 1, 4 };
char nodeName[] = "randomGen";
char brokerName[] = "animus.mine.nu";
PubSubClient *client;

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
  
  prevMillis = 0;
  pinMode(randomPin, INPUT);
}

unsigned int moistureValue = 0;
unsigned int lightValue = 0;

void loop() {
  client->loop();
  EthernetDHCP.maintain();
  if(millis() > prevMillis + UPDATE_PERIOD_MSEC) {
    prevMillis = millis();
    char buf[10];
    sprintf(buf, "%d", analogRead(randomPin));
    client->publish("randomGen/random", buf);
  }
}
  

const char* ip_to_str(const uint8_t* ipAddr)
{
  static char buf[16];
  sprintf(buf, "%d.%d.%d.%d\0", ipAddr[0], ipAddr[1], ipAddr[2], ipAddr[3]);
  return buf;
}
