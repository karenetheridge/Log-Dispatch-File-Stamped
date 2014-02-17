use strict;
use warnings;
use File::Spec::Functions qw(catfile);
use Test::More tests => 12;

use_ok('Log::Dispatch');
use_ok('Log::Dispatch::File::Stamped');

my ($hour,$mday,$mon,$year) = (localtime)[2..5];
my @files;

my %params = (
    name      => 'file',
    min_level => 'debug',
    filename  => catfile('t', 'logfile.txt'),
);
my @tests = (
  { expected => sprintf("logfile-%04d%02d%02d.txt", $year+1900, $mon+1, $mday),
    params   => \%params,
    message  => 'foo bar',
  },
  { expected => sprintf("logfile-%02d%02d.txt", $mday, $hour),
    params   => { %params, stamp_fmt => '%d%H' },
    message  => 'blah blah',
  },
);
for my $t (@tests) {
    my $dispatcher = Log::Dispatch->new;
    ok($dispatcher);
    my $file = catfile('t', $t->{expected});
    push @files, $file;
    my $stamped = Log::Dispatch::File::Stamped->new(%{$t->{params}});
    ok($stamped);
    $dispatcher->add($stamped);
    $dispatcher->log_to( name =>'file', level => 'info', message => $t->{message} );
    ok(-e $file);
    open my $fh, "<$file";
    ok($fh);
    local $/ = undef;
    my $line = <$fh>;
    close $fh;
    ok($line, $t->{message});
}
END {
    unlink @files if @files;
};
__END__
