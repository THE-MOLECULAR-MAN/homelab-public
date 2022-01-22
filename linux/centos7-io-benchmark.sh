#!/bin/bash
# Tim H 2021
#
# Benchmarking HDD IOPS and IO throughputin CentOS 7
# https://www.en.ee/checking-server-disks-performance-in-centos-7/

# install dependencies
yum install -q -y fio ioping

# IO throughput test
fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=test --filename=random_read_write.fio --bs=4k --iodepth=64 --size=4G --readwrite=randrw --rwmixread=75

# delete the temp file created in the step above
rm -f random_read_write.fio

# IOPS test
ioping -c 100 .
