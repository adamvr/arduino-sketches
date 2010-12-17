

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
char mime[65];

TinyXML xml;
uint8_t buffer[100];
uint16_t buflen = 100;
char message[] = "<eeml><environment></environment><data><value>1</value></data></eeml>";

void setup()
{
  Serial.begin(9600);
  xml.init((uint8_t*)&buffer,buflen,&XML_callback);
  Serial.println("Test test");
}

void loop()
{
  char *c = message;
  while(*c++) {
    xml.processChar(*c);
  }
  
  delay(5000);

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



