#include <Client.h>
#include <Ethernet.h>
#include <Server.h>

#include <inttypes.h>
#include <TinyXML.h>

byte mac[] = { 
  0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xEF };
byte ip[] = { 
  192, 168, 1, 45 };
byte gateway[] = { 
  192,168, 1, 1 };
byte subnet[] = { 
  255, 255, 255, 0 };

static uint8_t server[] = {
  168,143,162,100}; // IP addr of twitter.com
Client client(server, 80);
char mime[65];

TinyXML xml;
uint8_t buffer[150];
uint16_t buflen = 150;

void setup()
{
  Serial.begin(115200);
  //Serial.begin(57600);
  delay(2000);
  Serial.println("Tiny XML Test harness started");
  xml.init((uint8_t*)&buffer,buflen,&XML_callback);
  Ethernet.begin(mac, ip, gateway, subnet);
  mimeEncode("username:password");
  delay(2000);
}

void loop()
{
  Serial.println("Connecting");
  if (client.connect()) {
    Serial.println("Connected");
    client.println("GET /statuses/friends_timeline.xml HTTP/1.0");
    client.println("HOST: twitter.com");
    client.print("Authorization: Basic ");
    client.println(mime);
    client.println("User-Agent: Ardunino JGC");
    client.println();
    client.println();
    while (true)
    {
      if (client.available())
      {
        char c = client.read();
        //xml.processChar(c);
        //Serial.print(c);
        if (c=='<')
        {
          c=client.read();
          if (c=='?')
          {
            xml.processChar('<');
            xml.processChar('?');
            break;
          }

        }
      }
    }
    Serial.println("Waiting for response");
    //if (client.available()) {
    while (true)
    {
      if (client.available())
      {
        char c = client.read();
        xml.processChar(c);
        //Serial.print(c);
      }
    }


  }
  /*
if (Serial.available())
   {
   xml.processChar(Serial.read());
   }
   */  delay(1000);
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



static char mime_code(const char c)
{
  if (c < 26) return c+'A';
  if (c < 52) return c-26+'a';
  if (c < 62) return c-52+'0';
  if (c == 62) return '+';
  return '/';
}

void mimeEncode(const char *buf)
{
  int i = 0, j = 0, c[3];
  while (j < 64 && buf[i]) {
    c[0] = buf[i++];
    c[1] = buf[i] ? buf[i++] : 0;
    c[2] = buf[i] ? buf[i++] : 0;
    mime[j++] = mime_code(c[0]>>2);
    mime[j++] = mime_code(((c[0]<<4)&0x30) | (c[1]>>4));
    mime[j++] = c[1] ? mime_code(((c[1]<<2)&0x3c) | (c[2]>>6)) : '=';
    mime[j++] = c[2] ? mime_code(c[2]&0x3f) : '=';
  }
  mime[j] = 0;
}



