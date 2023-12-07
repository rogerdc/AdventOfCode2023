#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
# use bignum;

# my $data_file_name = "sampledata.txt";
my $data_file_name = "data.txt";

my $round = 2;

# Prototype hand hash:
# card0 => First card,
# card1 => Second card
# card2 => Third card
# card3 => Fourth card
# card4 => Fifth card
# bid => bid from data
# type => calculated type:
#   five_of_a_kind - 6
#   four_of_a_kind - 5
#   full_house - 4
#   three_of_a_kind -3 
#   two_pair - 2
#   one_pair - 1
#   high_card - 0

# No duplicate hands

sub hand_type_value
{
    my $type_string = shift;
    if ($type_string eq 'five_of_a_kind')
    {
        return 6;
    }
    elsif ($type_string eq 'four_of_a_kind')
    {
        return 5;
    }
    elsif ($type_string eq 'full_house')
    {
        return 4;
    }
    elsif ($type_string eq 'three_of_a_kind')
    {
        return 3;
    }
    elsif ($type_string eq 'two_pair')
    {
        return 2;
    }
    elsif ($type_string eq 'one_pair')
    {
        return 1;
    }
    elsif ($type_string eq 'high_card')
    {
        return 0;
    }
    else
    {
        die "Bad type string in hand_type_value: $type_string";
    }
}

sub card_value
{
    my $initial_value = shift;
    if ($initial_value eq 'A')
    {
        return 14;
    }
    elsif ($initial_value eq 'K')
    {
        return 13;
    }
    elsif ($initial_value eq 'Q')
    {
        return 12;
    }
    elsif ($initial_value eq 'J')
    {
        if ($round == 1)
        {
            return 11;
        }
        return 1;
    }
    elsif ($initial_value eq 'T')
    {
        return 10;
    }
    else
    {
        return $initial_value;
    }
}

open (my $data, "<", $data_file_name) or die "Cannot open < $data_file_name: $!";

my @hands;

while (my $line = readline($data))
{
    chomp $line;
    my ($hand_string, $bid) = split /[\s]+/, $line;
    my @cards = split //, $hand_string;
    my %hand = (
        card0 => $cards[0],
        card1 => $cards[1],
        card2 => $cards[2],
        card3 => $cards[3],
        card4 => $cards[4],
        bid => $bid,
    );
    my %hand_card_count = (
        A => 0,
        K => 0,
        Q => 0,
        J => 0,
        T => 0,
        9 => 0,
        8 => 0,
        7 => 0,
        6 => 0,
        5 => 0,
        4 => 0,
        3 => 0,
        1 => 0,
    );
    foreach my $card (@cards)
    {
        $hand_card_count{$card}++;
    }
    my $joker_count = $hand_card_count{J};
    if ($round != 1)
    {
        $hand_card_count{J} = 0;
    }
    my @card_counts = sort {$b <=> $a} values %hand_card_count;
    if ($round != 1)
    {
        $card_counts[0] += $joker_count;
    }
    if ($card_counts[0] == 5)
    {
        $hand{type} = 'five_of_a_kind';
    }
    elsif ($card_counts[0] == 4)
    {
        $hand{type} = 'four_of_a_kind';
    }
    elsif (($card_counts[0] == 3) && ($card_counts[1] == 2))
    {
        $hand{type} = 'full_house';
    }
    elsif ($card_counts[0] == 3)
    {
        $hand{type} = 'three_of_a_kind';
    }
    elsif (($card_counts[0] == 2) && ($card_counts[1] == 2))
    {
        $hand{type} = 'two_pair';
    }
    elsif ($card_counts[0] == 2)
    {
        $hand{type} = 'one_pair';
    }
    else
    {
        $hand{type} = 'high_card';
    }
    push @hands, \%hand;
}

close $data;


# my @sorted_descending_hands = sort sort_hands @hands;
my @sorted_descending_hands = sort 
{
    hand_type_value($a->{type}) <=> hand_type_value($b->{type}) 
    or 
    card_value($a->{card0}) <=> card_value($b->{card0})
    or 
    card_value($a->{card1}) <=> card_value($b->{card1})
    or 
    card_value($a->{card2}) <=> card_value($b->{card2})
    or 
    card_value($a->{card3}) <=> card_value($b->{card3})
    or 
    card_value($a->{card4}) <=> card_value($b->{card4})
    } @hands;

my @sorted_ascending_hands = reverse (@sorted_descending_hands);

my $winnings = 0;

for (my $i = 0; $i <= $#sorted_descending_hands; $i++)
{
    my $rank = 1 + $i;
    my $hand_winnings = $rank * $sorted_descending_hands[$i]->{bid};
    $winnings += $hand_winnings;
}

print "Winnings from this set of hands (Round $round): $winnings\n";