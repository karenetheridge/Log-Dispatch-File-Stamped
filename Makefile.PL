# $Id: Makefile.PL,v 1.3 2006-09-07 08:40:27 eric Exp $

use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'Log::Dispatch::File::Stamped',
    AUTHOR        => 'Eric Cholet <cholet@logilune.com>',
    VERSION_FROM  => 'lib/Log/Dispatch/File/Stamped.pm',
    ABSTRACT_FROM => 'lib/Log/Dispatch/File/Stamped.pm',
    PL_FILES      => {},
    PREREQ_PM     => {
                      'Log::Dispatch'       => 0,
                      'Log::Dispatch::File' => '2.38',
                      'Test::More'          => '0.88',
                    },
    dist          => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean         => { FILES => 'Log-Dispatch-File-Stamped-*' },
);
