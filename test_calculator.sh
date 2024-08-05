#!/bin/bash

# Define the Docker image
DOCKER_IMAGE="public.ecr.aws/l4q9w4c5/loanpro-calculator-cli:latest"

# Check if the Docker image is already downloaded
if [[ "$(docker images -q $DOCKER_IMAGE 2> /dev/null)" == "" ]]; then
  echo "Docker image not found locally. Downloading the latest version..."
  docker pull $DOCKER_IMAGE
else
  echo "Docker image found locally."
fi

run_test() {
  OPERATION=$1
  ARG1=$2
  ARG2=$3
  EXPECTED=$4

  echo "Running test: $OPERATION $ARG1 $ARG2"
  RESULT=$(docker run --rm ${DOCKER_IMAGE%:*} $OPERATION $ARG1 $ARG2 2>&1)
  echo "Result: $RESULT"
  if [[ "$RESULT" == *"$EXPECTED"* ]]; then
    echo "Test passed!"
  else
    echo "Test failed! Expected '$EXPECTED' but got '$RESULT'"
  fi
}

# Run tests

# Basic Addition Test
run_test "add" 7 3 "10"

# Basic Subtraction Test
run_test "subtract" 10 4 "6"

# Basic Multiplication Test
run_test "multiply" 6 5 "30"

# Basic Division Test
run_test "divide" 20 4 "5"

# Division by Zero Test
run_test "divide" 10 0 "Cannot divide by zero"

# Subtraction with Decimals
run_test "subtract" 1.0001 0.0001 "1.0000"

# Multiplication with Decimals
run_test "multiply" 1.0001 0.0001 "0.00010001"

# Division with Decimals
run_test "divide" 1.0001 0.0001 "10001"

# Scientific Notation
run_test "multiply" 1e+10 1e+10 "100000000000000000000"

# Decimal Precision
run_test "add" 1.00000001 1.00000001 "2.00000002"

# Infinity Operation
run_test "divide" 1e+100 1e-100 "Infinity"

# Negative Infinity Operation
run_test "divide" -1e+100 1e-100 "-Infinity"

# Negative Operands
run_test "add" -5 -3 "-8"

# Incorrect Number of Operands
run_test "add" 5 7 2 "Invalid argument. Must be a numeric value."

# Performance Test
for i in {1..10}; do
  run_test "add" $i $i "$((2 * i))"
done

# Stress Test
run_test "multiply" 9999999999999999 9999999999999999 "Functioning correctly"