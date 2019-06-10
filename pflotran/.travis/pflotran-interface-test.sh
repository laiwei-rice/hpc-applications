#!/bin/sh

export PETSC_DIR=$PWD/petsc; 
export PETSC_ARCH=petsc-arch

# Run regression tests
cd src/clm-pflotran;

make test
REGRESSION_EXIT_CODE=$?
if [ $REGRESSION_EXIT_CODE -ne 0 ]; then
  echo "Regression tests failed" >&2
  exit 1
else
  exit 0
fi

