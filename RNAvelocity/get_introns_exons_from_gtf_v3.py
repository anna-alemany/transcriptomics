import sys, os
import pybedtools

try:
    gtffile = sys.argv[1]
    if not os.path.isfile(gtffile):
        sys.exit('give existing gtffile')
    output = sys.argv[2]
except:
    sys.exit('give (1) gtffile; (2) output root')

a = pybedtools.BedTool(gtffile)
i = a.introns().saveas()
i.saveas(output + '_intron.bed')

e = a.filter(lambda b: b.fields[2] == 'exon').saveas()
ee = pybedtools.BedTool([(b.chrom, b.start, b.end, b.name, 'exon', b.strand) for b in e])
ee.saveas(output + '_exon.bed')
