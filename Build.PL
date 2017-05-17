use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Bio::SNP::TOPBOT',
    license             => 'perl',
    dist_abstract       => 'Determine Illumina TOPBOT strand',
    dist_author         => 'Rick Tankard <tankard@wehi.edu.au>',
    build_requires => {
        'Test::More' => '0.10',
    },
);

$builder->create_build_script();

