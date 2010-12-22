#include <SPI.h>
#include <Ethernet.h>
#include <inttypes.h>
#include <TinyXML.h>
#include <Base64.h>



// Enter a MAC address and IP address for your controller below.
// The IP address will be dependent on your local network:
byte mac[] = {  
  0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte ip[] = { 
  10,1,1,3 };
byte server[] = { 
  10,1,1,5 }; // Google

// Initialize the Ethernet client library
// with the IP address and port of the server 
// that you want to connect to (port 80 is default for HTTP):
Client client(server, 5222);

TinyXML xml;
uint8_t buffer[200];
uint16_t buflen = 200;
void callback(uint8_t, char*, uint16_t, char*, uint16_t);

enum connstate {
  INIT,
  AUTH_SELECT,
  AUTHENTICATING,
  AUTHENTICATED
};

connstate state = INIT;
int plainallowed = 0;

String streaminit = "<stream:stream "
"xmlns='jabber:client' "
"xmlns:stream='http://etherx.jabber.org/streams' "
"to='ceit.org' "
"version='1.0'>";

String plainauthreq = "<auth xmlns='urn:ietf:params:xml:ns:xmpp-sasl'"
"      mechanism='MD5-DIGEST'>=</auth>";


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
    client.print(streaminit);
  } 
  else {
    ;

  }
}

void loop()
{
  // if there are incoming bytes available 
  // from the server, read them and print them:
  int i = 0;
  while(client.available()) {
    char c = client.read();
    Serial.print(c);
    xml.processChar(c);
    i = 1;
  }

  if(i == 1) {
    Serial.println("");
  }

  if(state == AUTH_SELECT && plainallowed) {
    Serial.println("State = AUTH_SELECT");
    client.print(plainauthreq);
    state = INIT;   
  } 
  else {
    ;
  }    
}


void XML_callback( uint8_t statusflags, char* tagName,  uint16_t tagNameLen,  char* data,  uint16_t dataLen )
{
  if (statusflags & STATUS_START_TAG)
  {
    if ( tagNameLen )
    {
      /*
      Serial.print("Start tag ");
       Serial.println(tagName);
       */
    }
  }
  else if  (statusflags & STATUS_END_TAG)
  {
    /*
    Serial.print("End tag ");
     Serial.println(tagName);
     */
  }
  else if  (statusflags & STATUS_TAG_TEXT)
  {
    /*
    Serial.print("Tag:");
     Serial.print(tagName);
     Serial.print(" text:");
     Serial.println(data);
     */

    if(String(tagName) == "/echanism/mechanism") {
      state = AUTH_SELECT;
      if(String(data) == "PLAIN") {
        plainallowed = 1;
      }
    }
  }
  else if  (statusflags & STATUS_ATTR_TEXT)
  {
    /*
    Serial.print("Attribute:");
     Serial.print(tagName);
     Serial.print(" text:");
     Serial.println(data);
     */
  }
  else if  (statusflags & STATUS_ERROR)
  {
    /*
    Serial.print("XML Parsing error  Tag:");
     Serial.print(tagName);
     Serial.print(" text:");
     Serial.println(data);
     */
  }


}


