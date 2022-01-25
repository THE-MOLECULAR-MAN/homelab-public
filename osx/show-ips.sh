#!/bin/bash
# Tim H 2016
#
# Shows all the private IP addresses held on the current system

ifconfig | grep "10\.\|192\.168\|172\.16"
