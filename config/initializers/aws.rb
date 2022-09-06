AWSConfig = YAML.load_file("#{Rails.root}/config/aws.yml")[Rails.env]
AWS.config(access_key_id: AWSConfig['AWS_ACCESS_KEY_ID'], secret_access_key: AWSConfig['AWS_SECRET_ACCESS_KEY'], region: AWSConfig['AWS_REGION'])

$redis_data_layer = Redis.new(:host => AWSConfig['REDIS_HOST'], :port => AWSConfig['REDIS_PORT'])
