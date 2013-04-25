use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Log::Dispatch::File::Stamped',
    license             => 'perl',
    dist_author         => 'Eric Cholet <cholet@logilune.com>',
    dist_version_from   => 'lib/Log/Dispatch/File/Stamped.pm',
    requires => {
        'Test::More'          => 0.88,
        'Log::Dispatch'       => 0,
        'Log::Dispatch::File' => 2.38,
        'Test::TempDir'       => 0,
        'Path::Tiny'          => 0,
    },
    add_to_cleanup      => [ 'Log-Dispatch-File-Stamped-*' ],
);

$builder->create_build_script();
