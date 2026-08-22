#!/bin/bash

image_name="$1"
jdk_package="$2"

docker build -t "$image_name" \
  --build-arg USER_ID=$(id -u) \
  --build-arg GROUP_ID=$(id -g) \
	--build-arg JDK_PACKAGE="$jdk_package" . 

