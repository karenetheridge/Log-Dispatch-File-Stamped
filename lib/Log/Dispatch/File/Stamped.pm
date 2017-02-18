use strict;
use warnings;
package Log::Dispatch::File::Stamped;
# vim: set ts=8 sts=4 sw=4 tw=115 et :
# ABSTRACT: Logging to date/time stamped files
# KEYWORDS: log logging output file timestamp date rolling rotate

our $VERSION = '0.17';

use File::Basename        qw(fileparse);
use File::Spec::Functions qw(catfile);
use POSIX                 qw(strftime);

use Log::Dispatch::File 2.38;
use parent 'Log::Dispatch::File';

use Params::Validate qw(validate SCALAR);
Params::Validate::validation_options( allow_extra => 1 );

use namespace::clean 0.19;

sub _basic_init
{
    my $self = shift;

    $self->SUPER::_basic_init(@_);

    my %p = validate(
        @_,
        {
            stamp_fmt => {
                type => SCALAR,
                default => '%Y%m%d',
            },
        },
    );

    $self->{stamp_fmt} = $p{stamp_fmt};

    # cache of last timestamp used
    $self->{_stamp} = '';

    # split pathname into path, basename, extension
    @$self{qw(_name _path _ext)} = fileparse($self->{filename}, '\.[^.]+');

    # stored in $self->{filename} (overwrites original); used by _open_file()
    $self->_make_filename;
}

sub _make_filename
{
    my $self = shift;

    my $stamp = strftime($self->{stamp_fmt}, localtime);

    # re-use last filename if the stamp has not changed
    return $self->{filename} if $stamp eq $self->{_stamp};

    $self->{filename} = catfile(
        $self->{_path},
        join('-', $self->{_name}, $stamp) . ($self->{_ext} ? $self->{_ext} : '')
    );
}

sub log_message
{
    my $self = shift;

    # check if the filename is the same as last time...
    my $old_filename = $self->{filename};
    $self->_make_filename;

    # don't re-open if we use close-after-write - the superclass will do it
    if (not $self->{close} and $old_filename ne $self->{filename})
    {
        $self->_open_file;
    }

    $self->SUPER::log_message(@_);
}

1;
__END__

=pod

=head1 SYNOPSIS

  use Log::Dispatch::File::Stamped;

  my $file = Log::Dispatch::File::Stamped->new(
    name      => 'file1',
    min_level => 'info',
    filename  => 'Somefile.log',
    stamp_fmt => '%Y%m%d',
    mode      => 'append' );

  $file->log( level => 'emerg', message => "I've fallen and I can't get up\n" );

=head1 DESCRIPTION

This module subclasses L<Log::Dispatch::File> for logging to date/time-stamped
files, respecting all its configuration options. As with other L<Log::Dispatch>
handlers, the destination file is kept open for as long as the filename remains
constant (unless C<close_on_write> is set).

=head1 METHODS

=head2 new(%p)

This method takes the same set of parameters as L<Log::Dispatch::File::new()|Log::Dispatch::File/new>,
with the following differences:

=over 4

=item * filename ($)

The filename template. The actual timestamp will be appended to this filename
when creating the actual logfile. If the filename has an extension, the
timestamp is inserted before the extension. See examples below.

=item * stamp_fmt ($)

The format of the timestamp string. This module uses L<POSIX::strftime|POSIX/strftime> to
create the timestamp string from the current local date and time.
Refer to your platform's C<strftime> documentation for the list of allowed
tokens.

Defaults to C<%Y%m%d>.

=back

=head2 log_message( message => $ )

Sends a message to the appropriate output.  Generally this
shouldn't be called directly but should be called through the
C<log()> method (in L<Log::Dispatch::Output>).

=head1 EXAMPLES

=for stopwords txt

Assuming the current date and time is:

  % perl -e 'print scalar localtime'
  Sat Feb  8 13:56:13 2003

  Log::Dispatch::File::Stamped->new(
    name      => 'file',
    min_level => 'debug',
    filename  => 'logfile.txt',
  );

This will log to file F<logfile-20030208.txt>.

  Log::Dispatch::File::Stamped->new(
    name      => 'file',
    min_level => 'debug',
    filename  => 'logfile.txt',
    stamp_fmt => '%d%H',
  );

This will log to file F<logfile-0813.txt>.

=head1 SEE ALSO

=for :list
* L<Log::Dispatch::File>
* L<POSIX>
* L<Log::Dispatch::File::Rolling>
* L<Log::Dispatch::FileRotate>
* L<Log::Dispatch::FileWriteRotate>

=head1 ACKNOWLEDGEMENTS

=for stopwords Rolsky

Dave Rolsky, author of the L<Log::Dispatch> suite and many other
fine modules on CPAN.

This module was rewritten to respect all present (and future) options to
L<Log::Dispatch::File> by Karen Etheridge, <ether@cpan.org>.

=cut
