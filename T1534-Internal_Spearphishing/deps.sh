#!/bin/bash
apt-get update -y && apt-get install -y python3 python3-pip sendmail
pip3 install smtplib 2>/dev/null || true
