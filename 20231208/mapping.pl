#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use Math::BigInt qw(blcm);
use bignum;

# my $data_file_name = "sampledata1.txt";
# my $data_file_name = "sampledata2.txt";
# my $data_file_name = "sampledata3.txt";
my $data_file_name = "data.txt";

open (my $data, "<", $data_file_name) or die "Cannot open < $data_file_name: $!";

my @path; # 0 is left, 1 is right
my $nodes = {}; # {AAA} => ['BBB', 'CCC']

while (my $line = readline($data))
{
    chomp $line;
    if ($line =~ /^[RL]+$/)
    {
        my @path_as_letters = split //, $line;
        for (my $i = 0; $i <= $#path_as_letters; $i++)
        {
            if ($path_as_letters[$i] eq 'L')
            {
                $path[$i] = 0;
            }
            else
            {
                $path[$i] = 1;
            }
        }
    }
    elsif (!(length($line)))
    {
        # No op, blank line.
    }
    else
    {
        my @line_words = split /\s+/, $line;
        my $current_node = $line_words[0];
        $line_words[2] =~ /([\dA-Z]{3})/;
        my $left_node = $1;
        $line_words[3] =~ /([\dA-Z]{3})/;
        my $right_node = $1;
        $nodes->{$current_node} = [$left_node, $right_node]; 
    }
}

my @a_nodes = grep(/A$/, keys %{$nodes});
my @z_nodes = grep(/Z$/, keys %{$nodes});

my $instructional_path_length = $#path + 1;

print "Found " . ($#a_nodes + 1) . " simultaneous paths to take.\n";
print "Found " . ($#z_nodes + 1) . " Z nodes.\n";
print "Since they are the same, we may be able to just find the least common multiple of the different paths.\n";
print "If the path lengths are all divisible by the directional path length, then it's definitely the LCM.\n";

my @path_lengths;

foreach my $a_node (sort {$a cmp $b} @a_nodes)
{
    print "Path beginning on node $a_node has ";
    my $step_count = 0;
    my $path_index = 0;
    my $current_node = $a_node;
    while ($current_node !~ /Z$/)
    {
        $step_count++;
        $current_node = $nodes->{$current_node}[$path[$path_index]];
        $path_index++;
        if ($path_index > $#path)
        {
            $path_index = 0;
        }
    }
    push @path_lengths, $step_count;
    print "$step_count steps.";
    my $quotient = $step_count / $instructional_path_length;
    if (int($quotient) == $quotient)
    {
        print " Path length divided by $instructional_path_length is $quotient.";
    }
    if ($a_node eq 'AAA')
    {
        print " <--- Answer for single path (Round 1)";
    }
    print "\n";
}

my $lcm = 1 -> blcm(@path_lengths);
print "Shortest simultaneous path length: $lcm <--- Answer for round 2.\n";
