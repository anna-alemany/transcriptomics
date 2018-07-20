#!/bin/bash

if [ $# -ne 1 ]
then
    echo "Please, give input bam file (full name)"
    exit
fi

python ${path2scripts}/tablator.py $1
