#!/bin/bash
# Pre-bootstrap script to create the S3 bucket for Terraform State
# This bucket must exist before Terraform Init can run.

BUCKET_NAME="tf-state-$1-us-east-1"
aws s3api create-bucket --bucket $BUCKET_NAME --region us-east-1
aws s3api put-bucket-versioning --bucket $BUCKET_NAME --versioning-configuration Status=Enabled
echo "Bucket $BUCKET_NAME created and versioning enabled."
