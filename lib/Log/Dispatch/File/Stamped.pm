use strict;
use warnings;
package Log::Dispatch::File::Stamped;

use File::Basename        qw(fileparse);
use File::Spec::Functions qw(catfile);
use POSIX                 qw(strftime);

use vars qw(@ISA $VERSION);
use Log::Dispatch::File 2.38;
@ISA = qw(Log::Dispatch::File);

$VERSION = '0.10_003';      # for PAUSE
$VERSION = eval $VERSION;   # the real version (a string literal)

use Params::Validate qw(validate SCALAR);
Params::Validate::validation_options( allow_extra => 1 );


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

    # build the stamped file name
    my $filename = join '-', $self->{_name}, $stamp;
    $filename .= $self->{_ext} if $self->{_ext};
    $self->{filename} = catfile($self->{_path}, $filename);
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

=head1 NAME

Log::Dispatch::File::Stamped - Logging to date/time stamped files (UNAUTHORIZED RELEASE)

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

This module subclasses Log::Dispatch::File for logging to date/time
stamped files, respecting all its configuration options.

=head1 METHODS

=over 4

=item new(%p)

This method takes the same set of parameters as Log::Dispatch::File::new(),
with the following differences:

=over 4

=item -- filename ($)

The filename template. The actual timestamp will be appended to this filename
when creating the actual logfile. If the filename has an extension, the
timestamp is inserted before the extension. See examples below.

=item -- stamp_fmt ($)

The format of the timestamp string. This module uses POSIX::strftime to
create the timestamp string from the current local date and time.
Refer to your platform's C<strftime> documentation for the list of allowed
tokens.

Defaults to '%Y%m%d'.

=back

=item log_message( message => $ )

Sends a message to the appropriate output.  Generally this
shouldn't be called directly but should be called through the
"log()" method (in Log::Dispatch::Output).

=back

=head1 EXAMPLES

Assuming the current date and time is:

  % perl -e 'print scalar localtime'
  Sat Feb  8 13:56:13 2003

  Log::Dispatch::File::Stamped->new(
    name      => 'file',
    min_level => 'debug',
    filename  => 'logfile.txt',
  );

This will log to file 'logfile-20030208.txt'.

  Log::Dispatch::File::Stamped->new(
    name      => 'file',
    min_level => 'debug',
    filename  => 'logfile.txt',
    stamp_fmt => '%d%H',
  );

This will log to file 'logfile-0813.txt'.

=head1 SEE ALSO

L<Log::Dispatch::File>, L<POSIX>.

=head1 AUTHOR

Eric Cholet <cholet@logilune.com>

=head1 COPYRIGHT

The Log::Dispatch::File::Stamped is free software. You may
distribute it under the terms of either the GNU General
Public License or the Artistic License, as specified in the
Perl README file.

=head1 ACKNOWLEDGEMENTS

Dave Rolsky, author of the Log::Dispatch suite and many other
fine modules on CPAN.

This module was rewritten to respect all present (and future) options to
L<Log::Dispatch::File> by Karen Etheridge, <ether@cpan.org>.

=cut

