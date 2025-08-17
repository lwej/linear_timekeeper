#!/bin/bash

flutter test --coverage
lcov -r coverage/lcov.info
genhtml -o coverage coverage/lcov.info > coverage/output.txt

