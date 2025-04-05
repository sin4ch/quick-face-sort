# Quick Face Sort

An automated solution to sort images based on facial recognition. This tool scans through folders with large amounts of files and organizes media containing specific people you want to keep.

![](https://github.com/sin4ch/quick-face-sort/blob/main/images/automate-instead.jpg)

## Motivation

WhatsApp and other messaging apps often consume large portions of phone storage with unwanted media that we download but don't need long-term. However, some images contain important people (family, friends) that we want to keep. Manually sorting through hundreds or thousands of images is tedious.

Quick Face Sort automates this process using AWS Rekognition to identify and organize images based on faces.

## Architecture

![](https://github.com/sin4ch/quick-face-sort/blob/main/images/diagram-export-4-5-2025-11_12_25-PM.png)

## Setup Requirements

### Prerequisites
- AWS Account
- Terraform installed
- Python 3.9+
- Boto3 library

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/sin4ch/quick-face-sort.git
   cd quick-face-sort
   ```
2. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```
3. **Deploy infrastructure with Terraform**
   ```bash
   cd terraform
   terraform init
   terraform plan
   terraform apply
   ```
4. **Upload reference images**
  - Upload photos of people you want to identify to the reference S3 bucket
  - Each person should have at least one clear facial image
5. **Upload images to sort**
- Upload images to the database S3 bucket
- The Lambda function will automatically process these images
6. **View Results**
- Images will be organized into folders named after the reference images
- Check CloudWatch logs for processing details

## How It Works

- Reference photos are stored in a dedicated S3 bucket
- New photos uploaded to the database bucket trigger a Lambda function
- The Lambda function uses AWS Rekognition to compare faces
- Images with matching faces are organized into folders
- Logs are stored in CloudWatch for monitoring

## Future Plans

- **Local Version**: A local command-line version may be developed to process images (and videos) directly on your computer.

- **API Version**: An API version may be developed to allow integration with other application
