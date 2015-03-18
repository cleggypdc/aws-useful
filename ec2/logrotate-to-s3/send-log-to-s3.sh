#!/bin/bash
#get the instance id

#customisable vars
export AWS_ACCESS_KEY=your-aws-access-key-id
export AWS_SECRET_KEY=your-aws-secret-key
BUCKET_NAME="ec2-log-bucket"
INSTANCE_ID=`curl --silent http://169.254.169.254/latest/meta-data/instance-id | sed -e "s/i-//"`

#other vars
log_file_service=$1
log_file_directory=$2
tmp_gzip="/tmp/send-log-to-s3-${log_file_service}"
upload_time=$(date +"%H")

#looks for all files located in the log file directory
echo "Upload started for $log_file_service ..."
for f in $log_file_directory
do
	if [ "$f" != "$log_file_directory" ]
	then
		filename=$(basename $f)
		echo "Processing ${filename} ..."
		#gzip the file
		gzip -c $f > "${tmp_gzip}"
		#send to aws
		aws s3 cp $tmp_gzip s3://${BUCKET_NAME}/${INSTANCE_ID}/${log_file_service}/${filename}_${upload_time}.log.gz
	else
		echo "Ignoring empty $log_file_service log directory"
	fi
done
