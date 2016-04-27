# Bio-SNP-TOPBOT
Bio::SNP::TOPBOT, Perl module to determine strand of single nucleotide polymorphisms (SNPs) using Illumina's TOP/BOT designation. 

# Installation

Some understanding of how Perl finds modules may help to use this software. The TOPBOT.pm file will need to be in a Perl module directory under subdirectories Bio/SNP/, in Linux and Mac OS X this can be set by:
    export PERL5LIB:"Path to module directory":$PERL5LIB

For example, you may have the TOPBOT.pm file located at ~/perl/lib/Bio/SNP/TOPBOT.pm
In this example you would first run, or add to your .bashrc or .bash_profile
    export PERL5LIB:"~/perl/lib/":$PERL5LIB

# REQUIREMENTS

This module's `topbot_genome` depends on the SAMtools software being installed on the system. 
