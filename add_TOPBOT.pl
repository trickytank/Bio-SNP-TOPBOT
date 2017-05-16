#!/usr/bin/env perl 

=head1 add_TOPBOT.pl

=head1 Usage

add_TOPBOT.pl --ref hg19.fa coordinates.txt
cat coordinates.txt | add_TOPBOT.pl --ref hg19.fa 

Add TOPBOT designation to a delimited file

=head1 Options

--delim STRING
    Use this string as the delimiter instead of the default tab

--noheader
    Denotes that the file does not have a header line

--chrom STRING
--position NUMBER
--AB STRING
--A STRING
--B STRING

=cut

use 5.010;
use strict;
use warnings;
use autodie;
use Getopt::Long;
use Pod::Usage;
use Bio::SNP::TOPBOT;

GetOptions(
) or die "Error in command line arguments. Use --help for more information.\n";
if(@ARGV > 0) { die("Unused parameters in command line: " . join("\t", @ARGV)) };

if(defined($help)){
    pod2usage(
        -verbose => 2, 
        -output => \*STDOUT, 
        -width => 50,
        -noperldoc => ! -t STDOUT,
    );
}

# Process the input
while(<>) {

}

