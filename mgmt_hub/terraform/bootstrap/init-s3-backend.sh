#!/bin/bash
set -e 

if [ -z "$1" ]; then
  echo "❌ Error: Project name is required."
  echo "Usage: ./init-s3-backend.sh <project-name> [region]"
  exit 1
fi

PROJECT_NAME=$1
REGION=${2:-us-east-1} 
BUCKET_NAME="tf-state-${PROJECT_NAME}-${REGION}"

echo "🚀 Initializing Terraform State Backend..."
echo "Target Bucket: $BUCKET_NAME"
echo "Target Region: $REGION"

aws sts get-caller-identity > /dev/null 2>&1 || { 
  echo "❌ Error: AWS CLI is not authenticated. Please log in first."; 
  exit 1; 
}

if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
    echo "✅ Bucket $BUCKET_NAME already exists. Verifying security configurations..."
else
    echo "⏳ Creating bucket $BUCKET_NAME..."
    if [ "$REGION" == "us-east-1" ]; then
        aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION"
    else
        aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION" \
            --create-bucket-configuration LocationConstraint="$REGION"
    fi
fi

echo "🔒 Enabling bucket versioning..."
aws s3api put-bucket-versioning \
    --bucket "$BUCKET_NAME" \
    --versioning-configuration Status=Enabled

echo "🔒 Enabling default server-side encryption..."
aws s3api put-bucket-encryption \
    --bucket "$BUCKET_NAME" \
    --server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}'

echo "🔒 Applying strict Public Access Block..."
aws s3api put-public-access-block \
    --bucket "$BUCKET_NAME" \
    --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

echo "================================================="
echo "✅ S3 State Backend is fully bootstrapped and secured!"
echo "Bucket Name: $BUCKET_NAME"
echo "You may now run 'terraform init' in the root directory."
echo "================================================="