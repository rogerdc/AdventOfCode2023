#!/usr/bin/perl

use strict;
use warnings;

my @possible_game_ids;

my %maxes = (
    red     => 12,
    green   => 13,
    blue    => 14
);

open (my $data, "<", "data.txt") or die "Cannot open < data.txt: $!";

my $possible_game_number_sum = 0;
my $power_sum = 0;

GAME: while (my $line = readline($data))
{
    my %game_max = (
        red     => 0,
        green   => 0,
        blue    => 0
    );
    my $is_game_realistic = 1;
    chomp $line;
    print "Line: $line\n";
    my ($game_number_string, $game_result) = split /:/, $line;
    my ($trash, $game_number) = split / /, $game_number_string;
    print "Game number: $game_number\n";
    my @handfuls = split /;/, $game_result;
    foreach my $handful (@handfuls)
    {
        print "Handful: $handful\n";
        my @draws = split /,/, $handful;
        foreach my $draw (@draws)
        {
            print "Draw: $draw\n";
            $draw =~ /([\d]+)\s([\w]+)/;
            if (($2 ne "red") && ($2 ne "green") && ($2 ne "blue"))
            {
                die "No match on color. Color is '$2'\n";
            }
            if ($1 > $game_max{$2})
            {
                $game_max{$2} = $1;
            }
            if ($1 > $maxes{$2})
            {
                print "Game $game_number is impossible. Marking game impossible.\n";
                $is_game_realistic = 0;
            }
        }
    }
    print "Game number $game_number fully evaluated.\n";
    if ($is_game_realistic)
    {
        $possible_game_number_sum += $game_number;
    }
    my $game_power = $game_max{red} * $game_max{green} * $game_max{blue};
    print "Game power is: $game_power\n";
    $power_sum += $game_power;
}

print "Sum of possible game numbers: $possible_game_number_sum\n";
print "Sum of game powers: $power_sum\n";