#include <Ethernet.h>
#include <PubSubClient.h>
#include <EthernetDNS.h>
#include <EthernetDHCP.h>

const int UPDATE_PERIOD_MSEC = 5000;
unsigned long prevMillis;
int moisturePin = 5;
int lightPin = 0;
byte mac[] = //{ 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
//{ 0xAA, 0xBB, 0xBE, 0xEF, 0xFF, 0xEB };
{ 0x00, 0x00, 0xBE, 0xEF, 0xFF, 0xED }; 
byte mqttServer[] = { 192, 168, 1, 4 };
char name[] = "plantsensor";
char rootNode[] = "ceit/virginia/plant";
char moistureNode[] = "moisture_level";
char lightNode[] = "light_level";
char brokerName[] = "realtime.ngi.ibm.com";
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
  
  while(!client->connect("plantSensor")) {
    Serial.println("Unable to connect to MQTT broker");
    delay(5000);
  }
  
  prevMillis = 0;
  
}

unsigned int moistureValue = 0;
unsigned int lightValue = 0;

void loop() {
  client->loop();
  /*
  if(client->loop() == 0) {
    while(!client->connect(rootNode)) {
      delay(5000);
    }
  }
  */
  EthernetDHCP.maintain();
  
  moistureValue += analogRead(moisturePin);
  moistureValue /= 2;
  lightValue += analogRead(lightPin);
  lightValue /= 2;
  
  if(millis() - prevMillis > UPDATE_PERIOD_MSEC) {
    prevMillis = millis();
    
    char m[strlen(rootNode) + strlen(moistureNode) + 2];
    char l[strlen(rootNode) + strlen(lightNode) + 2];
    
    sprintf(m, "%s/%s", rootNode, moistureNode);
    sprintf(l, "%s/%s", rootNode, lightNode);
    
    
    
    Serial.println(l);
    Serial.println(m);
    
    char buf[10];
    
    Serial.print("Publishing moisture level: ");
    sprintf(buf, "%d", moistureValue);
    Serial.println(buf);
    client->publish(m, buf);
    
    Serial.print("Publishing light level: ");
    sprintf(buf, "%d", lightValue);
    Serial.println(buf);
    client->publish(l, buf);
   
    moistureValue = 0;
    lightValue = 0; 
  }
  
  
}
  

const char* ip_to_str(const uint8_t* ipAddr)
{
  static char buf[16];
  sprintf(buf, "%d.%d.%d.%d\0", ipAddr[0], ipAddr[1], ipAddr[2], ipAddr[3]);
  return buf;
}
