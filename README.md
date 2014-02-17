# NAME

Log::Dispatch::File::Stamped - Logging to date/time stamped files

# VERSION

version 0.13

# SYNOPSIS

    use Log::Dispatch::File::Stamped;

    my $file = Log::Dispatch::File::Stamped->new(
      name      => 'file1',
      min_level => 'info',
      filename  => 'Somefile.log',
      stamp_fmt => '%Y%m%d',
      mode      => 'append' );

    $file->log( level => 'emerg', message => "I've fallen and I can't get up\n" );

# DESCRIPTION

This module subclasses [Log::Dispatch::File](https://metacpan.org/pod/Log::Dispatch::File) for logging to date/time
stamped files, respecting all its configuration options.

# METHODS

## new(%p)

This method takes the same set of parameters as [Log::Dispatch::File::new()](https://metacpan.org/pod/Log::Dispatch::File#new),
with the following differences:

- filename ($)

    The filename template. The actual timestamp will be appended to this filename
    when creating the actual logfile. If the filename has an extension, the
    timestamp is inserted before the extension. See examples below.

- stamp\_fmt ($)

    The format of the timestamp string. This module uses [POSIX::strftime](https://metacpan.org/pod/POSIX#strftime) to
    create the timestamp string from the current local date and time.
    Refer to your platform's `strftime` documentation for the list of allowed
    tokens.

    Defaults to `%Y%m%d`.

## log\_message( message => $ )

Sends a message to the appropriate output.  Generally this
shouldn't be called directly but should be called through the
`log()` method (in [Log::Dispatch::Output](https://metacpan.org/pod/Log::Dispatch::Output)).

# EXAMPLES

Assuming the current date and time is:

    % perl -e 'print scalar localtime'
    Sat Feb  8 13:56:13 2003

    Log::Dispatch::File::Stamped->new(
      name      => 'file',
      min_level => 'debug',
      filename  => 'logfile.txt',
    );

This will log to file `logfile-20030208.txt`.

    Log::Dispatch::File::Stamped->new(
      name      => 'file',
      min_level => 'debug',
      filename  => 'logfile.txt',
      stamp_fmt => '%d%H',
    );

This will log to file `logfile-0813.txt`.

# SEE ALSO

[Log::Dispatch::File](https://metacpan.org/pod/Log::Dispatch::File), [POSIX](https://metacpan.org/pod/POSIX).

# ACKNOWLEDGEMENTS

Dave Rolsky, author of the Log::Dispatch suite and many other
fine modules on CPAN.

This module was rewritten to respect all present (and future) options to
[Log::Dispatch::File](https://metacpan.org/pod/Log::Dispatch::File) by Karen Etheridge, <ether@cpan.org>.

# AUTHORS

- Eric Cholet <cholet@logilune.com>
- Karen Etheridge <ether@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2003 by Karen Etheridge.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
