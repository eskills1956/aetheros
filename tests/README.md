# Aether OS Tests

This directory contains unit tests and integration tests for Aether OS components.

## Directory Structure

```
tests/
├── unit/              # Unit tests for individual components
│   ├── test_libaether.cpp
│   └── CMakeLists.txt
├── integration/       # Integration tests for system services
│   └── test_system_services.sh
└── README.md
```

## Running Tests

### Unit Tests

Build and run unit tests:

```bash
cd tests/unit
mkdir build && cd build
cmake ..
make
./test_libaether
```

Or use the test target from the main Makefile:

```bash
make test
```

### Integration Tests

Run integration tests after building the system:

```bash
source build/envsetup.sh
make all
./tests/integration/test_system_services.sh
```

## Test Coverage

### Unit Tests

- **test_libaether.cpp**: Tests for the native FFI library
  - Initialization and shutdown
  - Battery level reading
  - Brightness control
  - Volume control
  - WiFi control
  - Bluetooth control
  - Airplane mode
  - System information
  - Low power mode

### Integration Tests

- **test_system_services.sh**: Tests for system services
  - Service binary existence
  - Library existence
  - Service executability

## Adding New Tests

### Unit Tests

1. Create a new test file in `tests/unit/`
2. Add the test executable to `tests/unit/CMakeLists.txt`
3. Use the TEST() macro for individual test cases

### Integration Tests

1. Create a new shell script in `tests/integration/`
2. Make it executable: `chmod +x tests/integration/your_test.sh`
3. Follow the pattern in existing integration tests
