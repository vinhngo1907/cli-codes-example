#!/bin/bash
# install httpd
yum update -y
yum install -y httpd.x86_64
systemctl start httpd.service
systemctl enable httpd.service
EC2_AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone/)
echo "<h1>Hello AWS from $(hostname -f) in AZ: $EC2_AZ</h1>" > /var/www/html/index.html