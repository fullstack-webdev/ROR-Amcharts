AWSConfig = YAML.load_file("#{Rails.root}/config/aws.yml")[Rails.env]
S3DirectUpload.config do |c|
  c.access_key_id = AWSConfig['AWS_ACCESS_KEY_ID']
  c.secret_access_key = AWSConfig['AWS_SECRET_ACCESS_KEY']
  c.bucket = AWSConfig['BUCKET']
  c.region = ''
  c.url = 'https://' + AWSConfig['BUCKET'] + '.s3.amazonaws.com/'
end