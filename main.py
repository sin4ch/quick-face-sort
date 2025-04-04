import boto3
import json
import os
import logging

s3 = boto3.client('s3')
rekognition = boto3.client('rekognition')

database_bucket = os.environ["database_bucket"]
reference_bucket = os.environ["reference_bucket"]

reference_images = []
database_images = []

# Get objects from the database bucket:
def get_database_objects():
    response = s3.list_objects_v2(Bucket=database_bucket)
    return response

# def compare_faces(SourceImage = {'S3Object': {'Name': ''}}, TargetImage = {'S3Object': {'Name': ''}}, SimilarityThreshold = 90): 
#     return 
