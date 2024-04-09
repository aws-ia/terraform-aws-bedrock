#!/bin/bash

## NOTE: paths may differ when running in a managed task. To ensure behavior is consistent between
# managed and local tasks always use these variables for the project and project type path
PROJECT_PATH=${BASE_PATH}/project
PROJECT_TYPE_PATH=${BASE_PATH}/projecttype

echo "Starting Functional Tests"
cd ${PROJECT_PATH}

#********** Terraform Test **********

# Look up the mandatory test file
MANDATORY_TEST_PATH="./tests/01_mandatory.tftest.hcl"
if test -f ${MANDATORY_TEST_PATH}; then
    echo "File ${MANDATORY_TEST_PATH} is found, resuming test"
    # Run Terraform test
    terraform init
    terraform test
else
    echo "File ${MANDATORY_TEST_PATH} not found. You must include at least one test run in file ${MANDATORY_TEST_PATH}"
    (exit 1)
fi 

if [ $? -eq 0 ]; then
    echo "Terraform Test Successfull"
else
    echo "Terraform Test Failed"
    exit 1
fi

echo "End of Functional Tests"