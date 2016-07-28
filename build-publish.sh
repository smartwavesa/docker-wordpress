#!/bin/bash

set -e

usage="Usage:	build-publish  sudo  docker_build_opt docker_build_credentials docker_build_name docker_build_location aws_credentials \n

sudo : to execute with sudo \n

docker_build_opt : all the docker options except the image name /tag \n

docker_build_credentials : name of the credentials defined in Jenkins, to build the docker image (if needed ex : git credentials). \n

docker_build_name : the image's name /tag \n

docker_build_location : the location of the Dockerfile \n

aws_credentials : name of the credentials defined in Jenkins, to login on AWS \n
"

function help
{
	echo -e $usage
	exit 0
}

function error_exit
{
	echo -e "$1 \n

$usage \n

$2 \n" 1>&2
	exit 1
}


if [ ! -z $1 ] 
	then
	if [ $1 != "sudo" ] && [ $1 != "help" ]
		then
		error_exit "The first argument must be \"sudo\" or empty."
	else
		if [ $1 == "help" ]
			then
			help
		fi
	fi
fi

if [ -z "$4" ]
	then
	error_exit "\"docker_build_name\" is mandatory."
fi

if [ -z "$5" ]
	then
	error_exit "\"docker_build_location\" is mandatory."
fi


if [ -z "$6" ]
	then
	error_exit "\"aws_credentials\" is mandatory."
fi


docker_build_cmd="$1 docker build $2 -t $4 $5"

eval docker_build_credentials=\$$3

if [ ! -z $docker_build_credentials ];
	then
	USERNAME=${docker_build_credentials%:*}
	PASSWORD=${docker_build_credentials#*:}
	REPLACE=USERNAME
	docker_build_cmd=${docker_build_cmd/$REPLACE/$USERNAME}
	REPLACE=PASSWORD
	docker_build_cmd=${docker_build_cmd/$REPLACE/$PASSWORD}
fi

eval $docker_build_cmd

[ $? != 0 ] && \
error "Docker image build failed !" && exit 1


eval aws_credentials=\$$6

AWS_ACCESS_KEY_ID=${aws_credentials%:*}
AWS_SECRET_ACCESS_KEY=${aws_credentials#*:}

ecr_get_login="$1 docker run --rm  -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY -e AWS_DEFAULT_REGION=eu-west-1 anigeo/awscli ecr get-login"

$1 `$ecr_get_login`

eval "$1 docker push $4"

exit 0