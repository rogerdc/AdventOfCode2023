#!/usr/bin/perl

use strict;
use warnings;

open (my $data, "<", "data.txt") or die "Cannot open < data.txt: $!";

my $total_digits_only = 0;
my $total_digits_and_words = 0;

while (my $line = readline($data))
{
    chomp $line;
    print "This line: $line\n";
    my $reversed_line = reverse $line;
    print "This line reversed: $reversed_line\n";
    $line =~ /([\d])/;
    print "First digit (Digits only): $1\n";
    my $this_line_number = 10 * $1;
    $reversed_line =~ /([\d])/;;
    print "Second digit (Digits only): $1\n";
    $this_line_number += $1;
    print "Total for this line (digits only): $this_line_number\n";
    $total_digits_only += $this_line_number;
    print "Running total (Digits only): $total_digits_only\n";
    $line =~ /([\d]|one|two|three|four|five|six|seven|eight|nine)/i;
    for ($1)
    {
        if (/one/)
        {
            $this_line_number = 10 * 1;
        }
        elsif (/two/)
        {
            $this_line_number = 10 * 2;
        }
        elsif (/three/)
        {
            $this_line_number = 10 * 3;
        }
        elsif (/four/)
        {
            $this_line_number = 10 * 4;
        }
        elsif (/five/)
        {
            $this_line_number = 10 * 5;
        }
        elsif (/six/)
        {
            $this_line_number = 10 * 6;
        }
        elsif (/seven/)
        {
            $this_line_number = 10 * 7;
        }
        elsif (/eight/)
        {
            $this_line_number = 10 * 8;
        }
        elsif (/nine/)
        {
            $this_line_number = 10 * 9;
        }
        else
        {
            $this_line_number = 10 * $1;
        }
    }
    $reversed_line =~ /([\d]|eno|owt|eerht|ruof|evif|xis|neves|thgie|enin)/i;
    for ($1)
    {
        if (/eno/)
        {
            $this_line_number += 1;
        }
        elsif (/owt/)
        {
            $this_line_number += 2;
        }
        elsif (/eerht/)
        {
            $this_line_number += 3;
        }
        elsif (/ruof/)
        {
            $this_line_number += 4;
        }
        elsif (/evif/)
        {
            $this_line_number += 5;
        }
        elsif (/xis/)
        {
            $this_line_number += 6;
        }
        elsif (/neves/)
        {
            $this_line_number += 7;
        }
        elsif (/thgie/)
        {
            $this_line_number += 8;
        }
        elsif (/enin/)
        {
            $this_line_number += 9;
        }
        else
        {
            $this_line_number += $1;
        }
    }
    print "Total for this line (Digits and words): $this_line_number\n";
    $total_digits_and_words += $this_line_number;
    print "Running total (Digits and words): $total_digits_and_words\n";
}

print "Total (Digits only): $total_digits_only\n";
print "Total (Digits and words): $total_digits_and_words\n";