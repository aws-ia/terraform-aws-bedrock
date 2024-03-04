#!/bin/bash -e

## NOTE: paths may differ when running in a managed task. To ensure behavior is consistent between
# managed and local tasks always use these variables for the project and project type path
PROJECT_PATH=${BASE_PATH}/project
PROJECT_TYPE_PATH=${BASE_PATH}/projecttype

echo "Starting Static Tests"

cd ${PROJECT_PATH}
terraform init
terraform validate

#********** tflint ********************
echo 'Starting tflint'
tflint --init --config ${PROJECT_PATH}/.config/.tflint.hcl
MYLINT=$(tflint --force --config ${PROJECT_PATH}/.config/.tflint.hcl)
if [ -z "$MYLINT" ]
then
    echo "Success - tflint found no linting issues!"
else
    echo "Failure - tflint found linting issues!"
    echo "$MYLINT"
    exit 1
fi
#********** tfsec *********************
echo 'Starting tfsec'
MYTFSEC=$(tfsec . --config-file ${PROJECT_PATH}/.config/.tfsec.yml || true)
if [[ $MYTFSEC == *"No problems detected!"* ]];
then
    echo "Success - tfsec found no security issues!"
    echo "$MYTFSEC"
else
    echo "Failure - tfsec found security issues!"
    echo "$MYTFSEC"
    exit 1
fi

#********** Checkov Analysis *************
echo "Running Checkov Analysis"
MYCHECKOV=$(checkov --config-file ${PROJECT_PATH}/.config/.checkov.yml || true)
if [- z "$MYCHECKOV" ]
then 
    echo "Success - checkov found no security issues!"
    echo "$MYCHECKOV"
else
    echo "Failure - checkov found security issues!"
    echo "$MYCHECKOV"
    exit 1
fi

#********** Markdown Lint **************
echo 'Starting markdown lint'
MYMDL=$(mdl --config ${PROJECT_PATH}/.config/.mdlrc .header.md examples/*/.header.md || true)
if [ -z "$MYMDL" ]
then
    echo "Success - markdown lint found no linting issues!"
else
    echo "Failure - markdown lint found linting issues!"
    echo "$MYMDL"
    exit 1
fi
#********** Terraform Docs *************
echo 'Starting terraform-docs'
TDOCS="$(terraform-docs --config ${PROJECT_PATH}/.config/.terraform-docs.yaml --lockfile=false ./)"
git add -N README.md
GDIFF="$(git diff --compact-summary)"
if [ -z "$GDIFF" ]
then
    echo "Success - Terraform Docs creation verified!"
else
    echo "Failure - Terraform Docs creation failed, ensure you have precommit installed and running before submitting the Pull Request"
    exit 1
fi
#***************************************
echo "End of Static Tests"
