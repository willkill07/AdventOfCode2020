#!/usr/bin/env perl
use strict;
use warnings;

use List::Util qw/sum/;

sub read_input {
  local $/ = "\n\n";
  my ($filename) = @ARGV;
  open my $fd, '<', $filename;
  my @data = <$fd>;
  close $fd;
  map { s/\n/ /g } @data;
  @data
}

sub part1 {
  1 if ($_ =~ /(?=.*byr)(?=.*iyr)(?=.*eyr)(?=.*hgt)(?=.*hcl)(?=.*ecl)(?=.*pid)/);
}

sub part2 {
  1 if ($_ =~ /(?=.*iyr:(201\d|2020) )(?=.*eyr:(202\d|2030) )(?=.*hcl:#[0-9a-f]{6} )(?=.*pid:(\d{9})(?!\d))(?=.*byr:(19[2-9]\d|200[0-2]) )(?=.*ecl:(amb|blu|brn|gry|grn|hzl|oth) )(?=.*hgt:((1[5-8]\d|19[0-3])cm|(59|6\d|7[0-6])in) )/);
}

my @input = read_input();

my $p1 = sum( map{ part1($_) } @input );
my $p2 = sum( map{ part2($_) } @input );

print $p1 . "\n";
print $p2 . "\n";