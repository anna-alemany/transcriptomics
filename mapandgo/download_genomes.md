## how to downlaod genome
https://www.ebi.ac.uk/training/online/course/ensembl-browsing-chordate-genomes/get-whole-genomes-ftp

http://www.ensembl.org/info/data/ftp/index.html

'dna' - unmasked genomic DNA sequences.

'dna_rm' - masked genomic DNA. Interspersed repeats and low complexity regions are detected with the RepeatMasker tool and masked by replacing repeats with 'N's.

'dna_sm' - soft-masked genomic DNA. All repeats and low complexity regions have been replaced with lowercased versions of their nucleic base

## C. elegans
rsync -av rsync://ftp.ensembl.org/ensembl/pub/release-95/fasta/caenorhabditis_elegans/dna/ .

rsync -av rsync://ftp.ensembl.org/ensembl/pub/release-94/fasta/caenorhabditis_elegans/dna/ .

rsync -av rsync://ftp.ensembl.org/ensembl/pub/release-95/gtf/caenorhabditis_elegans/

rsync -av rsync://ftp.ensembl.org/ensembl/pub/release-94/gtf/caenorhabditis_elegans/

## Danio rerio
rsync -av rsync://ftp.ensembl.org/ensembl/pub/release-93/fasta/danio_rerio/dna/ .

## Homo sapiens
rsync -av rsync://ftp.ensembl.org/ensembl/pub/release-93/fasta/homo_sapiens/dna/*primary_assembly* .

## Mus musculus
rsync -av rsync://ftp.ensembl.org/ensembl/pub/release-93/fasta/mus_musculus/dna/*primary_assembly* .
