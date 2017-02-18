use strict;
use warnings;

use Test::More 0.88;
use Test::Fatal;
use Path::Tiny;
use POSIX 'strftime';
use Log::Dispatch::File::Stamped;

my $tempdir = Path::Tiny->tempdir;
my @localtime = (localtime);
my @gmtime = (gmtime);

note 'localtime: ', join(' ', @localtime);
note 'gmtime:    ', join(' ', @gmtime);

my %args = (
    min_level => 'debug',
    filename => $tempdir->child('foo.log')->stringify,
    stamp_fmt => '%Y%m%d%H',
);

{
    my $logger = Log::Dispatch::File::Stamped->new(%args);
    is(
        $logger->{filename},
        $tempdir->child(strftime('foo-' . $args{stamp_fmt} . '.log', @localtime)),
        'localtime is used by default',
    );
}

{
    my $logger = Log::Dispatch::File::Stamped->new(%args, time_function => 'localtime');
    is(
        $logger->{filename},
        $tempdir->child(strftime('foo-' . $args{stamp_fmt} . '.log', @localtime)),
        'localtime is used by request',
    );
}

{
    my $logger = Log::Dispatch::File::Stamped->new(%args, time_function => 'gmtime');
    is(
        $logger->{filename},
        $tempdir->child(strftime('foo-' . $args{stamp_fmt} . '.log', @gmtime)),
        'gmtime is used by request',
    );
}

{
    like(
        exception { Log::Dispatch::File::Stamped->new(%args, time_function => 'ethertime') },
        qr/time_function.*ethertime/,
        'no support for anything but localtime, gmtime',
    );
}

done_testing;
