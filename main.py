from boto3 import *
import json
import os
import logging

# Initialize clients
s3 = client('s3')
rekognition = client('rekognition')

# Get bucket names from environment variables
database_bucket = os.environ.get("database_bucket")
reference_bucket = os.environ.get("reference_bucket")

reference_images = []
database_images = []

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Get objects from the database bucket
def get_database_objects():
    response = s3.list_objects_v2(Bucket=database_bucket)
    objects = []
    if 'Contents' in response:
        for obj in response['Contents']:
            objects.append(obj['Key'])
    logger.info(f"Found {len(objects)} objects in database bucket")
    return objects

# Get objects from the reference bucket
def get_reference_objects():
    response = s3.list_objects_v2(Bucket=reference_bucket)
    objects = []
    if 'Contents' in response:
        for obj in response['Contents']:
            objects.append(obj['Key'])
    logger.info(f"Found {len(objects)} objects in reference bucket")
    return objects

# Compare faces between source and target images
def compare_faces(source_image, target_image, similarity_threshold=90):
    try:
        response = rekognition.compare_faces(
            SourceImage={
                'S3Object': {
                    'Bucket': reference_bucket,
                    'Name': source_image
                }
            },
            TargetImage={
                'S3Object': {
                    'Bucket': database_bucket,
                    'Name': target_image
                }
            },
            SimilarityThreshold=similarity_threshold
        )
        return response
    except Exception as e:
        logger.error(f"Error comparing faces: {str(e)}")
        return None

# Process all images and organize matches
def process_images():
    # Get all images from both buckets
    global reference_images, database_images
    reference_images = get_reference_objects()
    database_images = get_database_objects()
    
    # Track matches for each reference image
    matches = {}
    
    # Compare each reference image with all database images
    for ref_image in reference_images:
        matches[ref_image] = []
        
        for db_image in database_images:
            # Skip non-image files
            if not db_image.lower().endswith(('.png', '.jpg', '.jpeg', '.gif', '.bmp', '.webp')):
                continue
                
            comparison = compare_faces(ref_image, db_image)
            
            # Check if we got a valid response and if there are face matches
            if comparison and 'FaceMatches' in comparison and len(comparison['FaceMatches']) > 0:
                # If we have matches above threshold
                for match in comparison['FaceMatches']:
                    similarity = match['Similarity']
                    matches[ref_image].append({
                        'image': db_image,
                        'similarity': similarity
                    })
                    logger.info(f"Match found: {ref_image} matches {db_image} with similarity {similarity}%")
                    
                    # If very high confidence match, move the image to a folder named after the reference image
                    if similarity > 95:
                        folder_name = os.path.splitext(ref_image)[0]
                        new_key = f"{folder_name}/{db_image}"
                        
                        # Copy the object to the new location
                        s3.copy_object(
                            Bucket=database_bucket,
                            CopySource={'Bucket': database_bucket, 'Key': db_image},
                            Key=new_key
                        )
                        logger.info(f"Moved {db_image} to folder {folder_name}")
    
    return matches

# Lambda handler
def lambda_handler(event, context):
    try:
        if not database_bucket or not reference_bucket:
            return {
                'statusCode': 500,
                'body': json.dumps('Environment variables for bucket names not set')
            }
            
        results = process_images()
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Image processing complete',
                'matches_found': sum(len(matches) for matches in results.values()),
                'reference_images_processed': len(reference_images),
                'database_images_processed': len(database_images)
            })
        }
    except Exception as e:
        logger.error(f"Error in lambda handler: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps(f'Error processing images: {str(e)}')
        }

# For local testing
if __name__ == "__main__":
    # Set environment variables for local testing
    os.environ["database_bucket"] = "quicksort-database-bucket-20250404"
    os.environ["reference_bucket"] = "quicksort-reference-bucket-20250404"
    
    result = lambda_handler(None, None)
    print(result)