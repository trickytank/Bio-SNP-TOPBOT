# NAME

Bio::SNP::TOPBOT Determine the TOP/BOT strand 

# SYNOPSIS

    use Bio::SNP::TOPBOT; 

    # Finding strand of SNP rs11804171 with a reference sequence.
    # Requires installation of samtools in users PATH
    $reference_file = 'hg19.fa'; # reference sequence file
    $chrom = 'chr1';
    $position = 723819;
    $allele_a = 'A';
    $allele_b = 'T';
    topbot_genome $reference_file, $chrom, $position, $allele_a, $allele_b;

    # Finding strand of SNP rs11804171, SNP is assumed to be in the middle.
    $sequence = 'AAAGTACAA';
    $allele_a = 'A';
    $allele_b = 'T';
    topbot_sequence $sequence, $allele_a, $allele_b;

    # With the location of the SNP in the sequence given. 
    $sequence = 'AGAAAGTACAA';
    $position = 7; 
    topbot_sequence $sequence, $allele_a, $allele_b, $position;

# DESCRIPTION

For a SNP, determines whether the reference forward strand is the TOP or BOT strand as defined by Illumina. 
This scheme of strand designation is described in the
["TOP/BOT" Strand and "A/B" Allele](http://res.illumina.com/documents/products/technotes/technote_topbot.pdf) white paper released by Illumina. 

# REQUIREMENTS

This module's `topbot_genome` depends on the SAMtools software being installed on the system. 

# USAGE

Bio::SNP::TOPBOT can determine the TOP/BOT strand of a SNP on the reference forward 
strand with either a reference sequence file or the reference sequence directly. 

Both `topbot_genome` and `topbot_sequence` give similar outputs.
When the strand can be successfully determined the output will be 'TOP' or 'BOT'. 
When there is an error in determining the sequence then a string starting with 'ERROR' will be returned. 

For `topbot_sequence` only, when there is insufficient information to determine 
the strand (such as running out of sequence) then the empty string '' will be returned. 

# AUTHOR

Rick Tankard <trickytank@gmail.com>.

# SEE ALSO

# COPYRIGHT AND LICENSE

Copyright (c) Rick Tankard

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.
