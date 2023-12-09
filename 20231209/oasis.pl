#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use bignum;
use List::MoreUtils qw(all);

# my $data_file_name = "sampledata.txt";
my $data_file_name = "data.txt";

open (my $data, "<", $data_file_name) or die "Cannot open < $data_file_name: $!";

my @sequences;

while (my $line = readline($data))
{
    chomp $line;
    my $sequence = [ split /\s+/, $line ];
    push @sequences, $sequence;
}

close $data;

sub get_next_value
{
    my $current_sequence = shift;
    # print "In get_next_value.\n";
    # print "Current sequence:\n";
    # print Dumper($current_sequence);
    # print "Scalar of current sequence is: " . scalar(@{$current_sequence}) . "\n";
    # print $#{$current_sequence} . "\n";
    if (!(scalar(@{$current_sequence})))
    {
        die "get_next_value received a zero-length array.";
    }
    my $all_values_zero = 1;
    VALUES: foreach my $value (@{$current_sequence})
    {
        if ($value != 0)
        {
            $all_values_zero = 0;
            last VALUES;
        }
    }
    if ($all_values_zero)
    {
        return 0;
    }
    my $new_sequence = [];
    for (my $i = 1; $i <= $#{$current_sequence}; $i++)
    {
        push @{$new_sequence}, $current_sequence->[$i] - $current_sequence->[$i - 1];
    }
    return ($current_sequence->[$#{$current_sequence}] + get_next_value($new_sequence));
}

sub get_previous_value
{
    my $current_sequence = shift;
    # print "In get_previous_value.\n";
    # print "Current sequence:\n";
    # print Dumper($current_sequence);
    # print "Scalar of current sequence is: " . scalar(@{$current_sequence}) . "\n";
    # print $#{$current_sequence} . "\n";
    if (!(scalar(@{$current_sequence})))
    {
        die "get_previous_value received a zero-length array.";
    }
    my $all_values_zero = 1;
    VALUES: foreach my $value (@{$current_sequence})
    {
        if ($value != 0)
        {
            $all_values_zero = 0;
            last VALUES;
        }
    }
    if ($all_values_zero)
    {
        return 0;
    }
    my $new_sequence = [];
    for (my $i = $#{$current_sequence}; $i >= 1; $i--)
    {
        # print "Assembling new sequence...\n";
        # print "I: $i\n";
        # print "Current sequence[i]: " . $current_sequence->[$i] . "\n";
        # print "Current sequence[i - 1]: " . $current_sequence->[$i - 1] . "\n";
        # my $previous_value = $current_sequence->[$i] - $current_sequence->[$i - 1];
        # print "Value to prepend to new sequence: $previous_value\n";
        unshift @{$new_sequence}, $current_sequence->[$i] - $current_sequence->[$i - 1];
        # print "New sequence now:\n";
        # print Dumper($new_sequence);
    }
    # print "New sequence completed.\n";
    # print Dumper($new_sequence);
    return ($current_sequence->[0] - get_previous_value($new_sequence));
}


my $sum_of_next_values = 0;
my $sum_of_previous_values = 0;

foreach my $sequence (@sequences)
{
    my $next_value = get_next_value $sequence;
    my $previous_value = get_previous_value $sequence;
    print "Next value of this sequence is: $next_value, previous value of this sequence is: $previous_value\n";
    $sum_of_next_values += $next_value;
    $sum_of_previous_values += $previous_value;
}

print "Sum of next values: $sum_of_next_values\n";
print "Sum of previous values: $sum_of_previous_values\n";