#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use List::Util qw(min max);

# my $data_file_name = "sampledata.txt";
my $data_file_name = "data.txt";

open (my $data, "<", $data_file_name) or die "Cannot open < $data_file_name: $!";

my @schematic;
my $line_count = 0;
my $part_number_total = 0;
my $gear_ratio_total = 0;

while (my $line = readline($data))
{
    chomp $line;
    my @line_contents = (split //, $line);
    $schematic[$line_count] = $line;
    # print Dumper(@line_contents);
    $line_count++;
}

my $max_length = 0;

for (my $i = 0; $i <= $#schematic; $i++)
{
    while($schematic[$i] =~ m/(^|\D)(\d+)/g )
    {
        my $start_index = $-[2];
        my $end_index = $+[2];
        my $length = length($2);
        if ($length > $max_length)
        {
            $max_length = $length;
        }
        print "Found a number: Line number: $i: Value: $2 at start index $start_index and end index $end_index with length $length\n";
        my @lines_to_search;
        my @indexes_to_search;
        if ($i == 0)
        {
            @lines_to_search = (0, 1);
        }
        elsif ($i == $#schematic)
        {
            @lines_to_search = ($i - 1, $i);
        }
        else
        {
            @lines_to_search = ($i - 1, $i, $i + 1);
        }
        if ($start_index == 0)
        {
            @indexes_to_search = (0 .. $end_index);
        }
        elsif ($end_index == length($schematic[$i]))
        {
            @indexes_to_search = (($start_index - 1) .. ($end_index - 1));
        }
        else 
        {
            @indexes_to_search = (($start_index - 1) .. $end_index);
        }
        my $count_this_part_number = 0;
        foreach my $line_to_search (@lines_to_search)
        {
            foreach my $index_to_search (@indexes_to_search)
            {
                my $char_found = substr($schematic[$line_to_search], $index_to_search, 1);
                # print "DEBUG: Char found is $char_found\n";
                if (($char_found !~ /\d/) && ($char_found ne '.'))
                {
                    print "Found symbol '$char_found' at line $line_to_search index $index_to_search\n";
                    if ($count_this_part_number == 0)
                    {
                        $count_this_part_number = 1;
                        print "This part number counts!\n";
                    }
                }
            }
        }
        $part_number_total += ($2 * $count_this_part_number);
    }
    while($schematic[$i] =~ m/\*/g )
    {
        my $gear_index = $-[0];
        print "Found a gear on line $i at index $gear_index\n";
        my @lines_to_search;
        my $index_to_start_search;
        my $index_to_end_search;
        if ($i == 0)
        {
            @lines_to_search = (0, 1);
        }
        elsif ($i == $#schematic)
        {
            @lines_to_search = ($i - 1, $i);
        }
        else
        {
            @lines_to_search = ($i - 1, $i, $i + 1);
        }
        if ($gear_index == 0)
        {
            $index_to_start_search = 0;
            $index_to_end_search = 1;
        }
        elsif ($gear_index == length($schematic[$i]))
        {
            $index_to_start_search = $gear_index - 1;
            $index_to_end_search = $gear_index;
        }
        else 
        {
            $index_to_start_search = $gear_index - 1;
            $index_to_end_search = $gear_index + 1;
        }
        my @gear_part_numbers;
        my @character_searched;
        foreach my $line_to_search (@lines_to_search)
        {
            my @indexes_to_search;
            foreach my $index_to_search ($index_to_start_search .. $index_to_end_search)
            {
                $indexes_to_search[$index_to_search] = 0;
            }
            @character_searched[$line_to_search] = \@indexes_to_search
        }
        foreach my $line_to_search (@lines_to_search)
        {
            foreach my $index_to_search ($index_to_start_search .. $index_to_end_search)
            {
                # print "Line: $line_to_search\n";
                # print "Looking at line $line_to_search index $index_to_search. Searched: $character_searched[$line_to_search][$index_to_search]\n";
                if ($character_searched[$line_to_search][$index_to_search] == 0)
                {
                    # print "This location was not searched yet, so looking.\n";
                    # print "Marking line $line_to_search index $index_to_search as searched.\n";
                    $character_searched[$line_to_search][$index_to_search] = 1;
                    my $current_index = $index_to_search;
                    my $first_num_index;
                    my $last_num_index;
                    my $found_gear_part_number = 0;
                    # print "Current index is reset to $index_to_search. Substring is " . substr($schematic[$line_to_search], $current_index, 1) . "\n";
                    while (substr($schematic[$line_to_search], $current_index, 1) =~ /\d/)
                    {
                        # print "Working backwards to find number.\n";
                        # print "Digging for numbers. Current index is $current_index. Substring found was " . substr($schematic[$line_to_search], $current_index, 1) . "\n";
                        $character_searched[$line_to_search][$current_index] = 1;
                        # print "Set line $line_to_search index $current_index as searched.\n";
                        $first_num_index = $current_index;
                        $current_index--;
                        # print "Current index decremented. Substring is now " . substr($schematic[$line_to_search], $current_index, 1) . "\n";
                    }
                    $current_index = $index_to_search;
                    # print "Current index is reset to $index_to_search. Substring is " . substr($schematic[$line_to_search], $current_index, 1) . "\n";
                    while (substr($schematic[$line_to_search], $current_index, 1) =~ /\d/)
                    {
                        # print "Working forward to find number.\n";
                        # print "Digging for numbers. Current index is $current_index. Substring found was " . substr($schematic[$line_to_search], $current_index, 1) . "\n";
                        $character_searched[$line_to_search][$current_index] = 1;
                        # print "Set line $line_to_search index $current_index as searched.\n";
                        $last_num_index = $current_index;
                        $current_index++;
                        # print "Current index incremented. Substring is now " . substr($schematic[$line_to_search], $current_index, 1) . "\n";
                        $found_gear_part_number = 1;
                    }
                    if ($found_gear_part_number)
                    {
                        print "DEBUG: Found gear part number: ";
                        print substr($schematic[$line_to_search], $first_num_index, ($last_num_index - $first_num_index + 1));
                        print "\n";
                        push @gear_part_numbers, substr($schematic[$line_to_search], $first_num_index, ($last_num_index - $first_num_index + 1));
                    }
                }
            }
        }
        if ($#gear_part_numbers == 1)
        {
            print "There are two parts attached to this gear. They are $gear_part_numbers[0] and $gear_part_numbers[1]. Their gear ratio is: ";
            my $gear_ratio = $gear_part_numbers[0] * $gear_part_numbers[1];
            print "$gear_ratio\n";
            $gear_ratio_total += $gear_ratio;
        }
    }
}

print "Part number total: $part_number_total\n";
print "Gear ratio total: $gear_ratio_total\n";
