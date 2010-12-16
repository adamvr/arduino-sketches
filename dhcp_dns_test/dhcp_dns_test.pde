#include <PubSubClient.h>

#include <Ethernet.h>
#include <EthernetDHCP.h>
#include <EthernetDNS.h>

byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };

void setup() {
  Serial.begin(9600);
  Serial.println("Attempting to obtain an IP address");
  EthernetDHCP.begin(mac);

  const byte *ip = EthernetDHCP.ipAddress();
  const byte *gate = EthernetDHCP.gatewayIpAddress();
  const byte *dns = EthernetDHCP.dnsIpAddress();
  
  Serial.print("My IP: ");
  Serial.println(ip_to_str(ip));
  
  Serial.print("My Gateway: ");
  Serial.println(ip_to_str(gate));
  
    EthernetDNS.setDNSServer(EthernetDHCP.dnsIpAddress());
}
  
void loop() {
  char host[] = "google.com";
  byte hostIp[4];
  
  DNSError err = EthernetDNS.resolveHostName(host, hostIp);
  
  if(err == DNSSuccess) {
    Serial.print("IP address of ");
    Serial.print(host);
    Serial.print(": ");
    Serial.println(ip_to_str(hostIp));
  } else {
    /* Errors */
    Serial.println("Unable to resolve host name");
  }
  
  delay(1000);
  
  
  EthernetDHCP.maintain();
}

const char* ip_to_str(const uint8_t* ip) {
  static char buf[16];
  sprintf(buf, "%d.%d.%d.%d\0", ip[0], ip[1], ip[2], ip[3]);
  return buf;
}



