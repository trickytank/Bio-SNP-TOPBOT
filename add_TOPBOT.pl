#!/usr/bin/env perl 

=head1 add_TOPBOT.pl

=head1 Usage

add_TOPBOT.pl --ref hg19.fa coordinates.txt
cat coordinates.txt | add_TOPBOT.pl --ref hg19.fa 

Add TOPBOT designation to a delimited file

=head1 Synopsis

    SNPs that could not be called as TOP or BOT instead have an ERROR_* code.

=head1 Options

=head2 Required 

  --ref STRING 
    Path to the reference FASTA file, for use with samtools faidx.

=head2 Optional 

  --help
    Get help

  --delim STRING
    Use this string as the delimiter instead of the default tab.

  --noheader
    Denotes that the file has a no header line. 

  --chrom STRING
  --position NUMBER
  --A STRING
  --B STRING
  --AB STRING
    These options specify the column for the SNP chromosome, position, first allele (A), second allele (B), combined allele (AB). 
    If these are a number, then it refers to that column number, otherwise it is the name of the column according to the header.
    If the alleles are in two columns, use --A and --B, if they are in a single column use --AB. 
    --AB attempts to find exactly two alleles (A/G/C/T) on the column, any more or less will cause the program to die. 
    Defaults are the same as the option name, i.e. "chrom", "position", "A", "B".

  --insertcol = NUMBER
    Insert the TOPBOT designation after this column. When set to 0, this becomes the first column in the output.
    (default after last column)

  --errorfilter
    Filter SNPs with an error (no TOP or BOT strand)

  --comment STRING
    String denoting lines to be skipped if this string is the first non-whitespace on a line. (default '#')

  --skip NUMBER
    Skip this many lines from the start, including comment lines. (default 0)

  --chromprefix STRING
    Append this string to the start of chromosome names when looking in the FASTA reference. 
    A common alternative value for this is "chr".
    (default "")

=cut

use 5.010;
use strict;
use warnings;
use autodie;
use Getopt::Long;
use Pod::Usage;
use Bio::SNP::TOPBOT;

# Process command line options
my $help;
my $ref;
my $delim = "\t";
my $noheader = 0;
my $chrom = "chrom";
my $position = "position";
my $A;
my $B;
my $AB;
my $comment = "#";
my $skip = 0;
my $insertcol;
my $errorfilter;
my $chromprefix = "";

GetOptions(
    "help"          => \$help,
    "ref=s"         => \$ref,
    "delim=s"       => \$delim,
    "noheader"      => \$noheader,
    "chrom=s"       => \$chrom,
    "position=i"    => \$position,
    "A=s"           => \$A,
    "B=s"           => \$B,
    "AB=s"          => \$AB,
    "comment=s"     => \$comment,
    "skip=i"        => \$skip,
    "insertcol=i"   => \$insertcol,
    "errorfilter"   => \$errorfilter,
    "chromprefix=s" => \$chromprefix,

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

# check inputs and set any defaults
# check reference file exists
unless(defined($ref)) { die "Reference file (--ref) must be specified.\n" }
unless(-r $ref) { die "Reference file \"$ref\" is not readable.\n" }

# Check A and B column specification
if(defined($AB) && (defined($A) || defined($B))) {
    die "Cannot define --AB and at least one of --A or --B.\n";
}
if(defined($A) xor defined($B)) {
    die "Must define both --A and --B together";
}
if(!(defined($AB) || defined($A) || defined($B))) {
    # set A and B defaults
    $A = "A";
    $B = "B";
}

# check delim is at least one character
if(length($delim) == 0) { die "Delimiter --delim must be at least one character long\n" }

# check these are integers 0 or greater
if($skip !~ /^\d+$/) { die "--skip is not an integer of 0 or greater.\n"} 
if($insertcol !~ /^\d+$/) { die "--insertcol is not an integer of 0 or greater.\n" }

# check columns are set if --noheader
if($noheader) {
    my $hsay = "need to be integers with no header";
    if($chrom =~ /^\d+$/ || $position =~ /^\d+$/) { die "--chrom, --position $hsay.\n" }
    if(defined($AB)) {
        if($AB =~ /^\d+$/) { die "--AB $hsay\n" }
    } else {
        if($A =~ /^\d+$/ || $B ~ /^\d+$/) { die "--A and --B $hsay\n" }
    }
}


# Process the input
my $header_unseen = !$noheader; # assume column numbers are correct
while(<>) {
    next if /^\s*$comment/o;
    chomp;
    my @line = split /$delim/o;
    if($header_unseen) {
        # set the column numbers
        my %cols;
        @cols{@line} = (0..$#line);
        foreach ($chrom, $position, $A, $B, $AB) {
            unless(defined($_)) { next }
            if($_ =~ /^\d+$/) { next }
            if(defined($cols{$_})) {
                $_ = $cols{$_};
            } else {
                die "Column $_ not found.\n";
            }
        }
    }
    
    # TODO: add chromprefix

    # topbot_genome $ref, CHROM, POSITION, ALLELEA, ALLELEB;
    
    # TODO: process /^ERROR_/, maybe count them for the user
    # TODO: option to filter errors

    # insert into output

}

# STDERR summary of errors

