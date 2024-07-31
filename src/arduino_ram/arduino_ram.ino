#define MEMORY_SIZE 768 // Adjust this based on available SRAM

const int dataPins[8] = {2, 3, 4, 5, 6, 7, 8, 9}; // 8-bit data bus
const int lowerBytePin = 10;  // Pin to specify lower byte
const int upperBytePin = 11;  // Pin to specify upper byte
const int requestPin = 22;
const int controlSignalPin1 = 29; // Control signal bit 1
const int controlSignalPin2 = 30; // Control signal bit 2
const int lowerByteIndicatorPin = 31; // Pin to indicate lower byte being sent
const int upperByteIndicatorPin = 32; // Pin to indicate upper byte being sent
uint16_t memory[MEMORY_SIZE]; // 16-bit memory array
uint16_t currentAddress = 0; // current address
uint8_t currentLowerByte = 0; // current lower byte
uint8_t currentUpperByte = 0; // current upper byte

void writeMemory(uint16_t address, uint16_t data) {
  if (address < MEMORY_SIZE) {
    memory[address] = data;
  }
}

uint16_t readMemory(uint16_t address) {
  if (address < MEMORY_SIZE) {
    return memory[address];
  }
  return 0;
}

void setup() {
  for (int i = 0; i < 8; i++) {
    pinMode(dataPins[i], INPUT_PULLUP);
  }

  pinMode(requestPin, INPUT_PULLUP);
  pinMode(controlSignalPin1, INPUT_PULLUP);
  pinMode(controlSignalPin2, INPUT_PULLUP);
  pinMode(lowerBytePin, INPUT_PULLUP);
  pinMode(upperBytePin, INPUT_PULLUP);
  pinMode(lowerByteIndicatorPin, OUTPUT);
  pinMode(upperByteIndicatorPin, OUTPUT);

  Serial.begin(9600);
  digitalWrite(lowerByteIndicatorPin, LOW);
  digitalWrite(upperByteIndicatorPin, LOW);
}

void loop() {
  if (digitalRead(requestPin) == LOW) {
    uint8_t controlSignal = (digitalRead(controlSignalPin1) << 1) | digitalRead(controlSignalPin2);

    switch (controlSignal) {
      case 0b00: //no operation
        break;
      case 0b01: //write operation
        handleWriteOperation();
        break;
      case 0b10: //read operation
        handleReadOperation();
        break;
      case 0b11: //select address
        handleSelectAddress();
        break;
    }
  }
}

//select address instruction
void handleSelectAddress() {
  if (digitalRead(lowerBytePin) == HIGH) {
    currentLowerByte = readDataBus();
  } else if (digitalRead(upperBytePin) == HIGH) {
    currentUpperByte = readDataBus();
    currentAddress = (currentUpperByte << 8) | currentLowerByte;
  }
}

//write operation
void handleWriteOperation() {
  if (digitalRead(lowerBytePin) == HIGH) {
    currentLowerByte = readDataBus();
  } else if (digitalRead(upperBytePin) == HIGH) {
    currentUpperByte = readDataBus();
    uint16_t data = (currentUpperByte << 8) | currentLowerByte;
    writeMemory(currentAddress, data);
  }
}

//read operation
void handleReadOperation() {
  uint16_t data = readMemory(currentAddress);
  if (digitalRead(lowerBytePin) == HIGH) {
    digitalWrite(lowerByteIndicatorPin, HIGH); 
    writeDataBus(data & 0x00FF);
    digitalWrite(lowerByteIndicatorPin, LOW);
  } else if (digitalRead(upperBytePin) == HIGH) {
    digitalWrite(upperByteIndicatorPin, HIGH); 
    writeDataBus(data >> 8);
    digitalWrite(upperByteIndicatorPin, LOW);
  }
}

//read databus function
uint8_t readDataBus() {
  uint8_t data = 0;
  for (int i = 0; i < 8; i++) {
    data |= (digitalRead(dataPins[i]) << i);
  }
  return data;
}

//write data bus fucntion
void writeDataBus(uint8_t data) {
  for (int i = 0; i < 8; i++) {
    pinMode(dataPins[i], OUTPUT);
    digitalWrite(dataPins[i], (data >> i) & 0x01);
  }
  //set pins to input
  for (int i = 0; i < 8; i++) {
    pinMode(dataPins[i], INPUT_PULLUP);
  }
}