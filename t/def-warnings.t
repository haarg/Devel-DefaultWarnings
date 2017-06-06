use strict;
use Test::More tests => 6;
use Devel::DefaultWarnings;

BEGIN {
  $^W = 0;
}
BEGIN {
  ok warnings_default,
    'default warnings without pragma, without -w';
}
BEGIN {
  use warnings;
  BEGIN {
    ok !warnings_default,
      'not default warnings with pragma, without -w';
  }
}
BEGIN {
  no warnings;
  BEGIN {
    ok !warnings_default,
      'not default warnings with "no" pragma, without -w';
  }
}

BEGIN {
  $^W = 1;
}
BEGIN {
  ok warnings_default,
    'default warnings without pragma, with -w';
}
BEGIN {
  use warnings;
  BEGIN {
    ok !warnings_default,
      'not default warnings with pragma, with -w';
  }
}
BEGIN {
  no warnings;
  BEGIN {
    ok !warnings_default,
      'not default warnings with "no" pragma, with -w';
  }
}
