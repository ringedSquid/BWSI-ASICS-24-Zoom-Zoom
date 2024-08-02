const int WRITE_ENABLE_PIN = 2;
const int REGISTER_ENABLE_PIN = 3;
const int READ_ENABLE_PIN = 4;
const int LOWER_BIT_PIN = 5;
const int UPPER_BIT_PIN = 6;

const int LOWER_BYTE_IN_PIN = 7;
const int UPPER_BYTE_IN_PIN = 8;

const int DATA_BUS_PINS[] = {9, 10, 11, 12, 13, 14, 15, 16};

uint8_t sram[1024 * 1024]; // 1MB of SRAM

void setup() {
  pinMode(WRITE_ENABLE_PIN, INPUT);
  pinMode(REGISTER_ENABLE_PIN, INPUT);
  pinMode(READ_ENABLE_PIN, INPUT);
  pinMode(LOWER_BIT_PIN, INPUT);
  pinMode(UPPER_BIT_PIN, INPUT);

  pinMode(LOWER_BYTE_IN_PIN, OUTPUT);
  pinMode(UPPER_BYTE_IN_PIN, OUTPUT);

  for (int i = 0; i < 8; i++) {
    pinMode(DATA_BUS_PINS[i], INPUT);
  }

  memset(sram, 0, sizeof(sram));
}

void loop() {
  if (digitalRead(WRITE_ENABLE_PIN) == HIGH) {
    handleWriteOperation();
  }

  if (digitalRead(READ_ENABLE_PIN) == HIGH) {
    handleReadOperation();
  }
}

void handleWriteOperation() {
  static uint32_t address = 0;

  if (digitalRead(REGISTER_ENABLE_PIN) == HIGH && digitalRead(LOWER_BIT_PIN) == HIGH) {
    setDataBusDirection(INPUT);
    uint8_t lowerAddress = readBus(DATA_BUS_PINS);
    address = (address & 0xFFFFFF00) | lowerAddress;
    delayMicroseconds(1);
  }

  if (digitalRead(REGISTER_ENABLE_PIN) == HIGH && digitalRead(UPPER_BIT_PIN) == HIGH) {
    uint8_t upperAddress = readBus(DATA_BUS_PINS);
    address = (upperAddress << 8) | (address & 0xFFFF00FF);
    delayMicroseconds(1);
  }

  if (digitalRead(LOWER_BIT_PIN) == HIGH && digitalRead(REGISTER_ENABLE_PIN) == LOW) {
    setDataBusDirection(INPUT);
    uint8_t lowerData = readBus(DATA_BUS_PINS);
    sram[address] = lowerData;
    delayMicroseconds(1);
  }

  if (digitalRead(UPPER_BIT_PIN) == HIGH) {
    setDataBusDirection(INPUT);
    uint8_t upperData = readBus(DATA_BUS_PINS);
    sram[address + 1] = upperData;
    delayMicroseconds(1);
    setDataBusDirection(INPUT);
  }
}

void handleReadOperation() {
  static uint32_t address = 0;

  if (digitalRead(REGISTER_ENABLE_PIN) == HIGH && digitalRead(LOWER_BIT_PIN) == HIGH) {
    setDataBusDirection(INPUT);
    uint8_t lowerAddress = readBus(DATA_BUS_PINS);
    address = (address & 0xFFFFFF00) | lowerAddress;
    delayMicroseconds(1);
  }

  if (digitalRead(REGISTER_ENABLE_PIN) == HIGH && digitalRead(UPPER_BIT_PIN) == HIGH) {
    uint8_t upperAddress = readBus(DATA_BUS_PINS);
    address = (upperAddress << 8) | (address & 0xFFFF00FF);
    delayMicroseconds(1);
  }

  digitalWrite(LOWER_BYTE_IN_PIN, HIGH);
  if (digitalRead(LOWER_BYTE_IN_PIN) == HIGH) {
    setDataBusDirection(OUTPUT);
    writeBus(DATA_BUS_PINS, sram[address]);
    delayMicroseconds(1); //will most likely need to extend delay
    digitalWrite(LOWER_BYTE_IN_PIN, LOW);
  }

  digitalWrite(UPPER_BYTE_IN_PIN, HIGH);
  if (digitalRead(UPPER_BYTE_IN_PIN) == HIGH) {
    writeBus(DATA_BUS_PINS, sram[address + 1]);
    delayMicroseconds(1); //will most likely need to extend delay
    digitalWrite(UPPER_BYTE_IN_PIN, LOW);
  }
}

void setDataBusDirection(bool direction) {
  for (int i = 0; i < 8; i++) {
    pinMode(DATA_BUS_PINS[i], direction ? OUTPUT : INPUT);
  }
}

uint8_t readBus(const int* pins) {
  uint8_t value = 0;
  for (int i = 0; i < 8; i++) {
    value |= (digitalRead(pins[i]) << i);
  }
  return value;
}

void writeBus(const int* pins, uint8_t value) {
  for (int i = 0; i < 8; i++) {
    digitalWrite(pins[i], (value >> i) & 0x01);
  }
}
