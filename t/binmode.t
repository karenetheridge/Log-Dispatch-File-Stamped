use strict;
use warnings;
use File::Spec::Functions qw(catfile);
use Test::More;

my %params = (
    name      => 'file',
    min_level => 'debug',
    filename  => catfile('t', 'logfile.txt'),
);
my ($hour,$mday,$mon,$year) = (localtime)[2..5];
my @tests = (
  { expected => sprintf("logfile-%04d%02d%02d.txt", $year+1900, $mon+1, $mday),
    params   => {%params, 'binmode' => ':utf8'},
    message  => "foo bar\x{20AC}",
    expected_message => "foo bar\xe2\x82\xac",
  },
);
plan tests => 2 + 5 * @tests;

use_ok('Log::Dispatch');
use_ok('Log::Dispatch::File::Stamped');

my @files;

SKIP:
{
    skip "Cannot test utf8 files with this version of Perl ($])", 5 * @tests
        unless $] >= 5.008;

    for my $t (@tests) {
        my $dispatcher = Log::Dispatch->new;
        ok($dispatcher);
        my $file = catfile('t', $t->{expected});
        push @files, $file;
        my $stamped = Log::Dispatch::File::Stamped->new(%{$t->{params}});
        ok($stamped);
        $dispatcher->add($stamped);
        $dispatcher->log( level   => 'info', message => $t->{message} );
        ok(-e $file);
        open my $fh, "<$file";
        ok($fh);
        local $/ = undef;
        my $line = <$fh>;
        close $fh;
        is($line, $t->{expected_message}, 'output');
    }
}
END {
    unlink @files if @files;
};
