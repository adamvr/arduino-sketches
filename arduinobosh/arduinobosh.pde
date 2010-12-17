/*
  Web client
 
 This sketch connects to a website (http://www.google.com)
 using an Arduino Wiznet Ethernet shield. 
 
 Circuit:
 * Ethernet shield attached to pins 10, 11, 12, 13
 
 created 18 Dec 2009
 by David A. Mellis
 
 */

#include <SPI.h>
#include <Ethernet.h>

// Enter a MAC address and IP address for your controller below.
// The IP address will be dependent on your local network:
byte mac[] = {  0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte ip[] = { 10,1,1,3 };
byte server[] = { 10,1,1,5 }; // Google

// Initialize the Ethernet client library
// with the IP address and port of the server 
// that you want to connect to (port 80 is default for HTTP):
Client client(server, 5280);

String header = "POST /xmpp-httpbind HTTP/1.1\r\n"
                "Host: httpcm.ceit.org\r\n"
                "Accept-Encoding: gzip, deflate\r\n"
                "Content-Type: text/xml; charset=utf-8\r\n"
                "Content-Length: %d\r\n\r\n";
                
String body = "<body content='text/xml; charset=utf-8' "
               "from='mbed@ceit.org' "
               "hold='1' "
               "rid='1573741820' "
               "to='ceit.org' "
               "route='xmpp:ceit.org:5280' "
               "secure='true' "
               "wait='60' "
               "xml:lang='en' "
               "xmpp:version='1.0' "
               "xmlns='http://jabber.org/protocol/httpbind' "
               "xmlns:xmpp='urn:xmpp:xbosh'/>\r\n\r\n";

void setup() {
  // start the Ethernet connection:
  Ethernet.begin(mac, ip);
  // start the serial library:
  Serial.begin(9600);
  // give the Ethernet shield a second to initialize:
  delay(1000);
  Serial.println("connecting...");

  // if you get a connection, report back via serial:
  if (client.connect()) {
    Serial.println("connected");
    // Make a HTTP request:
    header = header.replace("%d", body.length());
    
    Serial.print(header);
    Serial.print(body);
    client.print(header);
    client.println(body);
  } 
  else {
    // kf you didn't get a connection to the server:
    Serial.println("connection failed");
    header = header.replace("%d", body.length());
    
    Serial.print(header);
    Serial.print(body);
    
  }
}

void loop()
{
  // if there are incoming bytes available 
  // from the server, read them and print them:
  if (client.available()) {
    char c = client.read();
    Serial.print(c);
  }

  // if the server's disconnected, stop the client:
  if (!client.connected()) {
    Serial.println();
    Serial.println("disconnecting.");
    client.stop();

    // do nothing forevermore:
    for(;;)
      ;
  }
}

