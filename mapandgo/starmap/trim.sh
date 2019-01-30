#!/bin/bash

path2trimgalore=/hpc/hub_oudenaarden/aalemany/bin/TrimGalore-0.4.3
path2cutadapt=/hpc/hub_oudenaarden/aalemany/bin

if [ $# -ne 1 ]
then
  echo "Please, give input file to trim"
  exit
fi

file2trim=$1

${path2trimgalore}/trim_galore --path_to_cutadapt ${path2cutadapt}/cutadapt ${file2trim}
mv ${file2trim}_trimming_report.txt ${file2trim%.f*}_trimmed_report.txt
