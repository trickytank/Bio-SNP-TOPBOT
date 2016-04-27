# svn $Revision: 935 $
# svn $LastChangedDate: 2015-04-08 12:24:36 +1000 (Wed, 08 Apr 2015) $

=head1 NAME

Bio::SNP::TOPBOT Determine the TOP/BOT strand 

=head1 SYNOPSIS

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

=head1 DESCRIPTION

For a SNP, determines whether the reference forward strand is the TOP or BOT strand as defined by Illumina. 
This scheme of strand designation is described in the
L<"TOP/BOT" Strand and "A/B" Allele|http://res.illumina.com/documents/products/technotes/technote_topbot.pdf> white paper released by Illumina. 

=head1 REQUIREMENTS

This module's C<topbot_genome> depends on the SAMtools software being installed on the system. 

=head1 USAGE

Bio::SNP::TOPBOT can determine the TOP/BOT strand of a SNP on the reference forward 
strand with either a reference sequence file or the reference sequence directly. 

Both C<topbot_genome> and C<topbot_sequence> give similar outputs.
When the strand can be successfully determined the output will be 'TOP' or 'BOT'. 
When there is an error in determining the sequence then a string starting with 'ERROR' will be returned. 

For C<topbot_sequence> only, when there is insufficient information to determine 
the strand (such as running out of sequence) then the empty string '' will be returned. 

=head1 AUTHOR

Rick Tankard E<lt>trickytank@gmail.comE<gt>.

=head1 SEE ALSO

=head1 COPYRIGHT AND LICENSE

Copyright (c) Rick Tankard

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut

use 5.010; 
use warnings;
use autodie; 
use POSIX qw(floor);

our(@ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS, $VERSION);

use Exporter; 
$VERSION = 0.02;
@ISA = qw(Exporter); 

@EXPORT     = qw (topbot_genome topbot_sequence);
@EXPORT_OK  = qw ();
%EXPORT_TAGS = ();

sub topbot_sequence;
sub topbot_genome;

sub topbot_genome {
    # Give TOP/BOT strand of SNP on a reference genome
    # Usage: 
    #   topbot_genome REFERENCE, CHROM, POSITION, ALLELEA, ALLELEB
    # REFERENCE: string of path to reference genome FASTA
    # CHROM: string of chromosome
    # POSITION: physical posistion on reference
    # ALLELEA: The first allele (order does not matter from ALLELEB)
    # ALLELEB: The second allele (order does not matter from ALLELEA)
    my ($reference, $chrom, $pos, $a, $b) = @_;
    # Check inputs
    $pos =~ /^\d+$/ or die "Not given a positive integer ($pos).";
    $a =~ /^[ACGT]$/i or die "Allele A is not a single nucleotide ($a).";
    $b =~ /^[ACGT]$/i or die "Allele B is not a single nucleotide ($b).";
    my $topbot; 
    for my $try_n_10 (0..5) {
        # try up to 50bp away from the SNP to check TOP/BOT status
        my $try_n = $try_n_10 * 10;
        my $start = $pos - $try_n;
        my $end = $pos + $try_n;
        my $sequence = qx/samtools faidx $reference $chrom:$start-$end/;
        $sequence =~ s/^.+\n//; # Remove Fasta sequence description
        $sequence =~ s/\n//g; # Remove excess newlines
        if(length($sequence) == 1 + 2 * $try_n) {
            $topbot = topbot_sequence $sequence, $a, $b;
        } else {
            last; 
        }
        if ($topbot) {
            last;
        }
    }
    if ($topbot eq '') {
        $topbot = 'ERROR_undetermined';
    }
    return $topbot;
}

sub topbot_sequence {
    # Give a TOP/BOT strand of a SNP when the sequence is given explicitly
    # Usage: 
    #   topbot_sequence SEQUENCE, ALLELEA, ALLELEB, POSITION
    #   topbot_sequence SEQUENCE, ALLELEA, ALLELEB
    # SEQUENCE: The input sequence
    # ALLELEA: The first allele (order does not matter from ALLELEB)
    # ALLELEB: The second allele (order does not matter from ALLELEA)
    # POSITION (optional): the position of the SNP in the sequence, 1-based
    my ($sequence, $a, $b, $pos) = @_;
    unless (length ($a) == 1 && length($b) == 1) {
        return('ERROR_input_alleles_not_single')
    }
    if ($a eq $b) {
        return('ERROR_same_allele');
    }
    if ($a gt $b) {
        # Ensure allele A is alphabetically first
        ($a, $b) = ($b, $a);
    }
    # Get sequences outside of base
    my $seqlen = length $sequence;
    if (defined($pos)) {
        if($pos > $seqlen) { die "Position ($pos) is greater than length of sequence" . length($sequence) }
        if($pos < 1) { die "Position ($pos) is smaller than 1" . length($sequence) }
        # slim down sequence
        if($pos * 2 > $seqlen) {
            $sequence = substr $sequence, 2 * $pos - $seqlen - 1;
        } else {
            $sequence = substr $sequence, 0, 2 * $pos - 1; 
        }
        $seqlen = length $sequence;
    } else {
        if ($seqlen % 2 == 0) { die "Input sequence must have an odd number of characters to find the middle. (length $seqlen)" } 
    }
    $pos = ($seqlen - 1) / 2;

    $sequence =~ /^(.{$pos})(.)(.{$pos})$/ or die "Internal error: Sequence not of expected length";
    my $p5 = uc $1;
    my $centre = uc $2;
    my $p3 = uc $3;
    if ($centre !~ /^[ACGT]$/) { 
        return "ERROR_refbase_nonACGT";
    }
    if ( "$a$b" =~ /^(AT|CG)$/ ) {
        # Ambigious
        if(length($p5) != length($p3)) {
            die "Internal error: different lengths of ends in $sequence";
        }
        if ($p5 eq '' || $p3 eq '') {
            return '';
        }
        unless($a eq $centre || $b eq $centre) {
            warn "The alleles $a and $b do not match the reference base $centre\n";
            return 'ERROR_seq_base_nomatch';
        }
        if ($p5 !~ /^[ACGT]+$/ || $p3 !~ /^[ACGT]+$/) { 
            warn "$p5, $p3";
            return 'ERROR_seq_nonACGT';
        }
        my @p5s = reverse (split '', $p5); 
        my @p3s = split '', $p3;
        BASEBYBASE: foreach my $left (@p5s) {
            my $right = shift @p3s;
            if(($left =~ /[AT]/) xor ($right =~ /[AT]/)) {
                if($left =~ /[AT]/) {
                    return 'TOP';
                } else {
                    return 'BOT';
                }
            }
        }
        
    } else {
        # Unambigious
        # Work out the reference SNP
        if ($a ne 'A') {
            $a =~ tr/ACGT/TGCA/;
            $b =~ tr/ACGT/TGCA/;
            ($a, $b) = ($b, $a);
            if ($a ne 'A') { die "Internal error: allele A == 'A' should be corrected by this line" }
        }
        # $a and $b are on TOP strand now
        if ($centre eq $a || $centre eq $b) { 
            # Is TOP
            return 'TOP';
        } else {
            # Is BOT
            return 'BOT';
        }
    }
    return ''; # Not determined
}

1; # Exit success
