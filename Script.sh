#!/bin/bash

#####################
# Author: Farhan Ahmed
# Date: 8th Jan, 2024
# LinkedIn: @farhanahmedindia

#####################

echo "Start creating S3 bucket"
echo "Input Bucket name:(Should be in small without underscore):"
read bucket_name
aws s3 mb s3://$bucket_name

# Uploading files to S3
echo "Enter folder path:"
read folder_path
aws s3 cp $folder_path s3://$bucket_name/ --recursive 

echo "Upload complete"

echo "Changing 'Bucket Ownership controls' to 'Bucket owner preferred'"
aws s3api put-bucket-ownership-controls \
    --bucket $bucket_name \
    --ownership-controls="Rules=[{ObjectOwnership=BucketOwnerPreferred}]"


echo "Change 'Block public access (bucket settings)' to off"
aws s3api put-public-access-block \
    --bucket $bucket_name \
    --public-access-block-configuration "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"

# Configure bucket as Static website
echo "Configuring bucket as Static website"
aws s3 website s3://$bucket_name/ --index-document index.html

echo "Make objects public using ACL"
aws s3api list-objects --bucket $bucket_name --query "Contents[].{Key: Key}" --output text | \
  xargs -I {} aws s3api put-object-acl --bucket $bucket_name --key {} --acl public-read


echo "URL of your website is http://$bucket_name.s3-website-$(aws configure get region).amazonaws.com"
