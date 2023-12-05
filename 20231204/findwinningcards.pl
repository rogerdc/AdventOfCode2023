#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

# my $data_file_name = "sampledata.txt";
my $data_file_name = "data.txt";

open (my $data, "<", $data_file_name) or die "Cannot open < $data_file_name: $!";

my @cards_raw;

while (my $line = readline($data))
{
    chomp $line;
    push @cards_raw, $line;
}

close $data;

my %cards;

foreach my $card (@cards_raw)
{
    my ($card_info, $winning_numbers_raw, $card_numbers_raw) = split /\||:/, $card;
    $card_info =~ /Card +([\d]+)/;
    my $card_number = $1;
    $winning_numbers_raw =~ s/^\s+|\s+$//g;
    $card_numbers_raw =~ s/^\s+|\s+$//g;
    # print "Card number: '$card_number', Winning number string: '$winning_numbers_raw', Number string: '$card_numbers_raw'\n";
    my @winning_numbers = sort ({$a <=> $b} split (/[\s]+/, $winning_numbers_raw));
    my @card_numbers = sort ({$a <=> $b} split (/[\s]+/, $card_numbers_raw));
    my $href = { winners => \@winning_numbers, numbers => \@card_numbers, copies => 1 };
    $cards{$card_number} = $href;
}

my $point_total = 0;

foreach my $card_number (sort {$a <=> $b} keys %cards)
{
    print "Working on card $card_number\n";
    my $winning_number_matches = 0;
    foreach my $winning_number (@{$cards{$card_number}->{winners}})
    {
        foreach my $drawn_number (@{$cards{$card_number}->{numbers}})
        {
            if ($winning_number == $drawn_number)
            {
                print "Card $card_number has a winning number: $drawn_number\n";
                $winning_number_matches++;
            }
        }
    }
    if ($winning_number_matches > 0)
    {
        my $card_point_total = 2 ** ($winning_number_matches - 1);
        print "Card $card_number is worth $card_point_total points.\n";
        $point_total += $card_point_total;
        for (my $i = 1; $i <= $winning_number_matches; $i++)
        {
            my $card_to_increment = $card_number + $i;
            $cards{$card_to_increment}->{copies} += $cards{$card_number}->{copies};
            print "Card " . ($card_number + $i) . " now has " . $cards{$card_number + $i}->{copies} . " copies.\n";
        }
    }
}

my $card_count = 0;

foreach my $card (sort { $a <=> $b } keys %cards)
{
    print "Card $card has " . $cards{$card}->{copies} . " copies.\n";
    $card_count += $cards{$card}->{copies};
}

print "Total points: $point_total\n";
print "Total cards: $card_count\n";