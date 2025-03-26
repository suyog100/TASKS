#!/bin/bash

# Extract lines with status code 200 from web_log.log and save to success.log
grep ' 200 ' web_log.log > success.log

