import boto3

s3 = boto3.resource('s3') 
b = s3.Bucket('PLAT-74-kdsjt304jt02349j-eu-west-1') 
b.create(CreateBucketConfiguration={ 'LocationConstraint': 'eu-west-1' }