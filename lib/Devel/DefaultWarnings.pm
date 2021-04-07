package Devel::DefaultWarnings;
use strict;
use warnings;

our $VERSION = '0.001002';
$VERSION =~ tr/_//d;

use Exporter ();
BEGIN { *import = \&Exporter::import }

our @EXPORT_OK = qw(
  warnings_default
  default_warnings_mask
  default_warning_categories
  enable_default_warnings
  non_default_warnings_mask
  non_default_warning_categories
  enable_non_default_warnings
);

BEGIN {
  my $check =
    "$]" >= 5.016 ? q{
      !defined ${^WARNING_BITS};
    }
    : "$]" >= 5.008008 ? q{
      my $w = ${^WARNING_BITS};
      local $^W = !$^W;
      $w ne ${^WARNING_BITS};
    }
    : "$]" >= 5.006001 ? q{
      my $depth = 0;
      while (my ($sub, $bits) = (caller(++$depth))[3,9]) {
        if ($sub =~ /::BEGIN$/) {
          local $^W = !$^W;
          my $new_bits = (caller($depth))[9];
          return $bits ne $new_bits;
        }
      }
      ${^WARNING_BITS} eq $warnings::NONE;
    }
    : q{
      ${^WARNING_BITS} eq $warnings::NONE;
    };
  eval "sub warnings_default () { $check }; 1" or die $@;
}

BEGIN {
  my $default_warnings = $warnings::DEFAULT;
  *default_warnings_mask = sub () { $default_warnings };
}
sub non_default_warnings_mask () {
  $warnings::Bits{all} & ~default_warnings_mask;
}

sub enable_non_default_warnings () {
  my $base_bits = ${^WARNING_BITS};
  if (!defined $base_bits) {
    $base_bits = $^W ? $warnings::Bits{all} : default_warnings_mask;
  }
  ${^WARNING_BITS} = $base_bits | non_default_warnings_mask;
}

sub enable_default_warnings () {
  my $base_bits = ${^WARNING_BITS};
  if (!defined $base_bits) {
    $base_bits = $^W ? $warnings::Bits{all} : default_warnings_mask;
  }
  ${^WARNING_BITS} = $base_bits | default_warnings_mask;
}

BEGIN {
  my @default_categories;
  my @non_default_categories;
  for my $category (sort keys %warnings::Bits) {
    my $bits = $warnings::Bits{$category};
    if (($bits & default_warnings_mask) eq $bits) {
      push @default_categories, $category;
    }
    elsif (($bits & ~default_warnings_mask) eq $bits) {
      push @non_default_categories, $category;
    }
  }

  *default_warning_categories     = sub () { @default_categories };
  *non_default_warning_categories = sub () { @non_default_categories };
}

1;

__END__

=head1 NAME

Devel::DefaultWarnings - Detect if warnings have been left at defaults

=head1 SYNOPSIS

  use Devel::DefaultWarnings qw(
    warnings_default
    enable_non_default_warnings
  );

  {
    BEGIN { my $def = warnings_default(); } #true;
  }
  {
    use warnings;
    BEGIN { my $def = warnings_default(); } #false;
  }
  {
    no warnings;
    BEGIN { my $def = warnings_default(); } #false;
  }
  {
    BEGIN { enable_non_default_warnings() }
    # all warnings are now enabled
  }
  {
    use experimental 'signatures';
    BEGIN { enable_non_default_warnings() }
    # all warnings are now enabled, except signature warnings
  }

=head1 DESCRIPTION

Check if lexical warnings have been changed from the default in the current
compiling context.

Can also enable non-default warnings.

=head1 FUNCTIONS

=over 4

=item warnings_default

Returns a true value if lexical warnings have been left as the default.

=item default_warnings_mask

Returns the bitmask to set in L<< C<${^WARNING_BITS}> | perlvar/${^WARNING_BITS} >>
to enable perl's default warnings. This includes things like C<severe> and
C<deprecated> warnings.

=item default_warning_categories

Returns all of the warning categories that are enabled by default. With these
categories enabled, it should match the default state of perl.

=item enable_default_warnings

Enables the default set of warnings in the current compiling context.

=item non_default_warnings_mask

Returns the bitmask to set in L<< C<${^WARNING_BITS}> | perlvar/${^WARNING_BITS} >>
to enable all warnings that are not included in the default set.

=item non_default_warning_categories

Returns all of the warning categories that are not enabled by default. Enabling
these will B<not> fully replicate enabling the L</non_default_warnings_mask>.
Some categories (C<experimental>) are partially included in the default set,
but include a distinct category that is not accessible in isolation.

=item enable_non_default_warnings

Enables the set of warnings that are not enabled by default in the current
compiling context.

=back

=head1 CAVEATS

=over 4

=item *

Some warning categories are not included in either
C<default_warning_categories> or C<non_default_warning_categories>.

=back

=head1 AUTHOR

haarg - Graham Knop (cpan:HAARG) <haarg@haarg.org>

=head1 CONTRIBUTORS

None yet.

=head1 COPYRIGHT

Copyright (c) 2014 the Devel::DefaultWarnings L</AUTHOR> and L</CONTRIBUTORS>
as listed above.

=head1 LICENSE

This library is free software and may be distributed under the same terms
as perl itself.

=cut
