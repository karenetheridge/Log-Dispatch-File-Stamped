#!/usr/bin/perl

use strict;
use warnings;
use File::Spec::Functions qw(catfile);
use FindBin               qw($Bin);
use Test::More;

plan tests => 6;

use_ok('Log::Dispatch');
use_ok('Log::Dispatch::File::Stamped');

my $dispatcher = Log::Dispatch->new;
ok($dispatcher);

my ($hour,$mday,$mon,$year) = (localtime)[2..5];
my $file = catfile($Bin, sprintf("logfile-%04d%02d%02d.txt", $year+1900, $mon+1, $mday));

my %params = (
    name        => 'file',
    min_level   => 'debug',
    permissions => 0600,
    filename  => catfile($Bin, 'logfile.txt'),
);
my $stamped = Log::Dispatch::File::Stamped->new(%params);
ok($stamped);

$dispatcher->add($stamped);
$dispatcher->log( level => 'info', message => 'foo' );
ok(-e $file);

my $perm =  (stat($file))[2] & 07777;
is ($perm, oct('0600'), 'permissions are correct');

END {
    unlink $file;
};
__END__
