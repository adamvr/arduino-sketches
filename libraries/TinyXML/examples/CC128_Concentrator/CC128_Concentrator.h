#ifndef CC128_Concentrator_h
#define CC128_Concentrator_h

// I2C commands
#define I2CADDR       0x32    // 7 bit address
#define COMMAND       0x00    // flags a command
#define SNAPSHOT      0x40    //  mask bit take a snapshot
#define CLEARCURRENT  0x80    //  mask bit clear current
#define READTIME      0x01    // read the time - 4 bytes
#define READTMPR      0x02    // read the temperature - 2 bytes
#define READELEC      0x03    // read the electotal + samples - 6 bytes
#define READGAS       0x04    // read the gastotal + samples - 4 bytes
#define READLIGHT     0x05    // read the gastotal + samples - 4 bytes
#define READERR       0x06    // read the error count - 2 bytes
#define READTMOUTCNT  0x07    // read timeout count - 2 bytes
#define READALL       0x10    // read all values - 22 bytes (32 bytes is max for Wire)
#define READINSTELEC  0x11    // read last electricty watts reading 2 bytes


struct CC128Data {
  uint32_t lastTimeReceived;  // secs since midnight
  uint16_t temperature;       // tenths of a degree
  uint32_t elecWatts;         // total of electricity Watts received
  uint16_t elecSamples;       // # electricity samples
  uint16_t gasCounts;         // number of positive Gas samples
  uint16_t gasSamples;        // # gas samples
  uint16_t lightValue;        // light value
  uint16_t errorCount;        // count of errors in the XML.
  uint16_t timeout_count;     // count of all protocol lockups
};

#endif
