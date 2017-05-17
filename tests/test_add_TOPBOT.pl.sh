# check manually what the outputs are
ref=$bahlolab_db/hg19/standard_gatk/hg19.fa

export PERL5LIB=${PWD}/perl/lib/:$PERL5LIB

perl add_TOPBOT.pl \
    --ref $ref \
    --chrom Chrom \
    --position physical_position_build37 \
    --insertcol 0 \
    test_data/linkdatagen_test_data.txt

