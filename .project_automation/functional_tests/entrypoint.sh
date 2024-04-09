#!/bin/bash

## WARNING: DO NOT modify the content of entrypoint.sh
# Use ./config/functional_tests/pre-entrypoint-helpers.sh or ./config/functional_tests/post-entrypoint-helpers.sh 
# to load any customizations or additional configurations

## NOTE: paths may differ when running in a managed task. To ensure behavior is consistent between
# managed and local tasks always use these variables for the project and project type path
PROJECT_PATH=${BASE_PATH}/project
PROJECT_TYPE_PATH=${BASE_PATH}/projecttype

#********** helper functions *************
pre_entrypoint() {
    if [ -f ${PROJECT_PATH}/.config/functional_tests/pre-entrypoint-helpers.sh ]; then
        echo "Pre-entrypoint helper found"
        source ${PROJECT_PATH}/.config/functional_tests/pre-entrypoint-helpers.sh
        echo "Pre-entrypoint helper loaded"
    else
        echo "Pre-entrypoint helper not found - skipped"
    fi
}
post_entrypoint() {
    if [ -f ${PROJECT_PATH}/.config/functional_tests/post-entrypoint-helpers.sh ]; then
        echo "Post-entrypoint helper found"
        source ${PROJECT_PATH}/.config/functional_tests/post-entrypoint-helpers.sh        
        echo "Post-entrypoint helper loaded"
    else
        echo "Post-entrypoint helper not found - skipped"
    fi
}

#********** Pre-entrypoint helper *************
pre_entrypoint

#********** Functional Test *************
/bin/bash ${PROJECT_PATH}/.project_automation/functional_tests/functional_tests.sh
if [ $? -eq 0 ]
then
    echo "Functional test completed"
    EXIT_CODE=0
else
    echo "Functional test failed"
    EXIT_CODE=1
fi

#********** Post-entrypoint helper *************
post_entrypoint

#********** Exit Code *************
exit $EXIT_CODE