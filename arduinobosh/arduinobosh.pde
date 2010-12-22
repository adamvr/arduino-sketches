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
#include <inttypes.h>
#include <TinyXML.h>


// Enter a MAC address and IP address for your controller below.
// The IP address will be dependent on your local network:
byte mac[] = {  0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte ip[] = { 10,1,1,3 };
byte server[] = { 10,1,1,5 }; // Google

// Initialize the Ethernet client library
// with the IP address and port of the server 
// that you want to connect to (port 80 is default for HTTP):
Client client(server, 5280);

TinyXML xml;
uint8_t buffer[200];
uint16_t buflen = 200;
void callback(uint8_t, char*, uint16_t, char*, uint16_t);

char rheader[] = "POST /xmpp-httpbind HTTP/1.1\r\n"
                "Host: httpcm.ceit.org\r\n"
                "Accept-Encoding: gzip, deflate\r\n"
                "Content-Type: text/xml; charset=utf-8\r\n"
                "Content-Length: %d\r\n\r\n%s";
                
char rbody[] = "<body content='text/xml; charset=utf-8' "
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
               
char 

void setup() {
  // set up the xml parser
  xml.init((uint8_t*)&buffer, buflen, &XML_callback);
  
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
    
    // The length of the header, plus the length of the body, plus the
    char msg[strlen(rheader) + strlen(rbody) + 3];
    sprintf(msg, rheader, strlen(rbody), rbody);
    
    Serial.print(msg);
    //Serial.print(body);
    client.print(msg);
    //client.println(body);
  } 
  else {
    // kf you didn't get a connection to the server:
    Serial.println("connection failed");
    //header.replace("%d", body.length());
    
    Serial.print(header);
    Serial.print(body);
    
    /*
    for(int i = 0; i < body.length(); i++) {
      xml.processChar(body[i]);
    }
    */
    
  }
}

void loop()
{
  // if there are incoming bytes available 
  // from the server, read them and print them:
  while(1) {
    while(client.available()) {
      char c = client.read();
      Serial.print(c);
    }
  }
}

void XML_callback( uint8_t statusflags, char* tagName,  uint16_t tagNameLen,  char* data,  uint16_t dataLen )
{
  if (statusflags & STATUS_START_TAG)
  {
    if ( tagNameLen )
    {
      Serial.print("Start tag ");
      Serial.println(tagName);
    }
  }
  else if  (statusflags & STATUS_END_TAG)
  {
    Serial.print("End tag ");
    Serial.println(tagName);
  }
  else if  (statusflags & STATUS_TAG_TEXT)
  {
    Serial.print("Tag:");
    Serial.print(tagName);
    Serial.print(" text:");
    Serial.println(data);
  }
  else if  (statusflags & STATUS_ATTR_TEXT)
  {
    Serial.print("Attribute:");
    Serial.print(tagName);
    Serial.print(" text:");
    Serial.println(data);
  }
  else if  (statusflags & STATUS_ERROR)
  {
    Serial.print("XML Parsing error  Tag:");
    Serial.print(tagName);
    Serial.print(" text:");
    Serial.println(data);
  }


}

