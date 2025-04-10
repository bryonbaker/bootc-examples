#! /bin/bash

# https://docs.aws.amazon.com/vm-import/latest/userguide/required-permissions.html#vmimport-role

aws iam create-role --role-name vmimport --assume-role-policy-document "file://C:\import\trust-policy.json"

aws iam put-role-policy --role-name vmimport --policy-name vmimport --policy-document "file://C:\import\role-policy.json"
