#!/usr/bin/perl

use strict;
use warnings;
use bignum;
use POSIX qw/ceil floor/;

# Sample data

# my @times = (7, 15, 30);
# my @distances = (9, 40, 200);

# my @times = (71530);
# my @distances = (940200);

# Real data

# my @times = (49, 78, 79, 80);
# my @distances = (298, 1185, 1066, 1181);

my @times = (49787980);
my @distances = (298118510661181);

my $ways_to_win_product = 1;

for (my $race_number = 0; $race_number <= $#times; $race_number++)
{
    my $win_count = 0;
    my $time = $times[$race_number];
    my $distance_to_beat = $distances[$race_number];
    print "Race time: $time ms. Distance to beat: $distance_to_beat mm\n";

    # Distance: d
    # Overall race time: t
    # Time to press the button: b

    # d = b (t - b)
    # d = b * t - b ** 2
    # (-1) * b ** 2 + t * b - d = 0

    # Hey, look, that's a quadratic equation in terms of b

    # Plugging in to the quadratic formula: 

    # Discriminant: sqrt(t ** 2 - 4 * -1 * -d) => sqrt(t ** 2 - 4 * d)
    # Solution 1: (-t - discriminant) / (2 * -1) => (t + discriminant) / 2
    # Solution 2: (-t + discriminant) / (2 * -1) => (t - discriminant) / 2

    my $discriminant = sqrt($time ** 2 - 4 * $distance_to_beat);
    my $solution_one = ($time - $discriminant) / 2;
    my $solution_two = ($time + $discriminant) / 2;

    print "Solution 1: $solution_one\n";
    print "Solution 2: $solution_two\n";
    print "Solution 1 ceiling: " . ceil($solution_one) . "\n";
    print "Solution 2 floor: " . floor($solution_two) . "\n";

    $win_count = floor($solution_two) - ceil($solution_one) + 1;

    foreach my $solution ($solution_one, $solution_two)
    {
        if (int($solution) == $solution)
        {
            $win_count--;
        }
    }

    print "Ways to win: $win_count\n";
    $ways_to_win_product *= $win_count;
}

print "Product of ways to win: $ways_to_win_product\n";