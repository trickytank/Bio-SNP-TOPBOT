#!/usr/bin/env perl 

# svn $Revision: 935 $
# svn $LastChangedDate: 2015-04-08 12:24:36 +1000 (Wed, 08 Apr 2015) $

=head1 Testing Bio::STR

=cut

use 5.014;
use warnings;
use Test::More tests => 15;
use Test::Exception;

use Bio::SNP::TOPBOT; 
my ($reference_file, $chrom, $position, $allele_a, $allele_b);

# Test the synopsis
# $reference_file = "$ENV{bahlolab_db}/hg19/standard_gatk/hg19.fa"; # reference sequence file
# $chrom = 'chr1';
# $position = 723819;
# $allele_a = 'A';
# $allele_b = 'T';
# is((topbot_genome $reference_file, $chrom, $position, $allele_a, $allele_b), 'BOT', "Testing an ambigious SNP from a FASTA file");

my $sequence;

# Finding strand of SNP rs11804171, SNP is assumed to be in the middle.
$sequence = 'AAAGTACAA';
$allele_a = 'A';
$allele_b = 'T';
is((topbot_sequence $sequence, $allele_a, $allele_b), 'BOT', "Testing an ambigous SNP from a sequence");

# With the location of the SNP in the sequence given. 
$sequence = 'AGAAAGTACAA';
$position = 7; 
is((topbot_sequence $sequence, $allele_a, $allele_b, $position), 'BOT', "Testing an ambigous SNP from a sequence at the given location");

is((topbot_sequence 'A', 'A', 'T'), '', "If undertermined then give an empty string");

is((topbot_sequence 'A', 'A', 'C'), 'TOP', "Should be able to determine TOPBOT with a single base in the sequence");

dies_ok { (topbot_sequence '', 'A', 'C') } 'Checking we die if there is no sequence given';
dies_ok { (topbot_sequence 'AGT', 'A', 'G', 10) } 'Should die if sequence position is too far out';
dies_ok { (topbot_sequence 'AGT', 'A', 'G', -5) } 'Should die if sequence position is too far out';
dies_ok { (topbot_sequence 'AGAT', 'A', 'G') } 'Should die if uneven and no position is given in sequence';

is( (topbot_sequence 'AGATA', 'AA', 'G'), 'ERROR_input_alleles_not_single', 'Should die if first allele is non-single'); 
is( (topbot_sequence 'AGATA', '', 'G'), 'ERROR_input_alleles_not_single', 'Should die if first allele is empty string');
is( (topbot_sequence 'AGATA', 'A', 'GTA'), 'ERROR_input_alleles_not_single', 'Should die if second allele is non-single');
is( (topbot_sequence 'AGATA', 'A', ''), 'ERROR_input_alleles_not_single', 'Should die if second allele is empyy string');


is((topbot_sequence 'AGEAT', 'A', 'C'), "ERROR_refbase_nonACGT", 'Recognises non ACGT sequence at SNP location');
is((topbot_sequence 'AGCET', 'C', 'G'), "ERROR_seq_nonACGT", 'Recognises non ACGT sequences outside SNP');

is((topbot_sequence 'AGCAT', 'A', 'T'), 'ERROR_seq_base_nomatch', 'Recognises mismatched allele at ambigious sites');





