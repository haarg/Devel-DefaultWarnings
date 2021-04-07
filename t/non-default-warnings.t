use strict;

BEGIN { $^W = 0 }

# safe to assume these will always be enabled by default
use warnings 'deprecated';
my $default_bits;
BEGIN { $default_bits = ${^WARNING_BITS} }

use warnings 'all';
my $all_bits;
BEGIN { $all_bits = ${^WARNING_BITS} }

use Test::More;

use Devel::DefaultWarnings qw(
  default_warnings_mask
  non_default_warnings_mask
  enable_non_default_warnings
  default_warning_categories
);

is default_warnings_mask, $default_bits,
  'default_warnings_mask gives correct default warning bits';

my $bits;
eval q{
  BEGIN { ${^WARNING_BITS} = $default_bits }
  BEGIN { enable_non_default_warnings }
  BEGIN { $bits = ${^WARNING_BITS} }
};

is $bits, $all_bits,
  'enable_non_default_warnings + defaults gives all warnings';

my @defaults = default_warning_categories;

ok scalar @defaults,
  'default category list includes some warnings';

(eval q{
  BEGIN { ${^WARNING_BITS} = $default_bits }
  no warnings 'deprecated';
  BEGIN { enable_non_default_warnings }
  package Other;
  sub { sub { $_[0]->() }->($_[0]) };
} or die $@)->(sub {
  ok !warnings::enabled('deprecated'),
    'enable_non_default_warnings does not re-enable disabled default warnings';
  ok warnings::enabled('malloc'),
    'enable_non_default_warnings does not disabled default warnings';
});

done_testing;
