package Auxiliary;

=head1 Auxiliary

This module contains functions to clean auxiliary files produced by TeX.

=cut

# -- Imports -------------------------------------------------------------------

use strict;
use warnings;

use Carp qw(croak);
use Data::Dumper;
use Env qw(TM_BUNDLE_SUPPORT);
use Exporter qw(import);
use File::Path qw(remove_tree);
use YAML qw(LoadFile);

# -- Exports -------------------------------------------------------------------

our @EXPORT_OK = qw(get_auxiliary_files remove_auxiliary_files);

# -- Functions -----------------------------------------------------------------

=head2 get_auxiliary_files

This function reads two lists of auxiliary files.

=head3 Arguments:

=over 4

=item tm_bundle_support

This string specifies the bundle support path of the LaTeX bundle.

=back

=head3 Returns:

The function returns two lists:

=over 4

=item * The first list contains a list of extensions. Each extension belongs to
a single auxiliary file produced by one of the various TeX commands.

=item * The second list contains a list of prefixes. Each prefix specifies the
first part of the name of a auxiliary directory produced by a TeX command.

=back

=cut

sub get_auxiliary_files {
    my ($tm_bundle_support) = @_;
    $tm_bundle_support ||= $TM_BUNDLE_SUPPORT;
    my $config_filepath = "$tm_bundle_support/config/auxiliary.yaml";

    open my $fh, '<', $config_filepath
      or croak "Can not open $config_filepath: $!";
    my $config = LoadFile($fh);
    close($fh);

    return $config->{'files'}, $config->{'directories'};
}

=head2 remove_auxiliary_files

Remove auxiliary files created by TeX commands.

=head3 Arguments:

=over 4

=item filename

This string specifies the name of a .tex file without its extension. This
function removes auxiliary files that TeX commands create when they translated
the file specified by this argument.

=item directory

This string specifies the directory that this function cleans from auxiliary
files.

=item tm_bundle_support

This string specifies the bundle support path of the LaTeX bundle.

=back

=cut

sub remove_auxiliary_files {
    my ( $name, $directory, $tm_bundle_support ) = @_;
    $tm_bundle_support ||= $TM_BUNDLE_SUPPORT;

    my ( $file_extensions, $directory_prefixes ) =
      get_auxiliary_files($tm_bundle_support);

    if ( defined($directory) ) {
        unlink( map { "$directory/$name.$_" } @$file_extensions );

        # Remove LaTeX bundle cache file
        unlink("$directory/.$name.lb");
        ( my $cache_name = $name ) =~ s/ /-/g;

        foreach
          my $dir ( map { "$directory/$_$cache_name" } @$directory_prefixes )
        {
            remove_tree($dir)
              if -d $dir && -w $dir;
        }
    }
    return;
}

1;
