#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use bignum;

# my $data_file_name = "sampledata.txt";
my $data_file_name = "data.txt";

sub get_mapped_value 
{
    # print "First parameter passed:\n";

    my $current_map = shift;

    my $source = shift;

    my $return_value = $source;

    # print "In get_mapped_value. Source is $source. Current map:\n";
    # print Dumper($current_map);

    foreach my $map_hash (@{$current_map})
    {
        # print "Examining hash:\n";
        # print "source_min: '" . $map_hash->{source_min} . "'\n";
        # print "source_max: '" . $map_hash->{source_max} . "'\n";
        # print "destination_start: '" . $map_hash->{destination_start} . "'\n";
        
        if (($source >= $map_hash->{source_min}) && ($source <= $map_hash->{source_max}))
        {
            $return_value = $map_hash->{destination_start} + ($source - $map_hash->{source_min});
            return $return_value;
        }
    }

    return $return_value;
}

open (my $data, "<", $data_file_name) or die "Cannot open < $data_file_name: $!";

my @seeds;
my @seeds_as_ranges;
my @seed_to_soil_map;
my @soil_to_fertilizer_map;
my @fertilizer_to_water_map;
my @water_to_light_map;
my @light_to_temperature_map;
my @temperature_to_humidity_map;
my @humidity_to_location_map;

my $current_map;

while (my $line = readline($data))
{
    chomp $line;
    if ($line =~ /^seeds: /)
    {
        my @split_line = split /[\s]+/, $line;
        shift @split_line;
        foreach my $seed_number (@split_line)
        {
            push @seeds, $seed_number;
        }
    }
    elsif ($line =~ /^([\S]+)\smap:$/)
    {
        if ($1 eq 'seed-to-soil')
        {
            $current_map = \@seed_to_soil_map;
        }
        elsif ($1 eq 'soil-to-fertilizer')
        {
            $current_map = \@soil_to_fertilizer_map;
        }
        elsif ($1 eq 'fertilizer-to-water')
        {
            $current_map = \@fertilizer_to_water_map;
        }
        elsif ($1 eq 'water-to-light')
        {
            $current_map = \@water_to_light_map;
        }
        elsif ($1 eq 'light-to-temperature')
        {
            $current_map = \@light_to_temperature_map;
        }
        elsif ($1 eq 'temperature-to-humidity')
        {
            $current_map = \@temperature_to_humidity_map;
        }
        elsif ($1 eq 'humidity-to-location')
        {
            $current_map = \@humidity_to_location_map;
        }
        else 
        {
            die "Unknown map name. Line was '$line', map name found was '$1'.";
        }
        print "Working on map $1.\n";
    }
    elsif ($line =~ /([\d]+)\s+([\d]+)\s+([\d]+)/)
    {
        print "Found map line: '$line'\n";
        my $destination_range_start = $1;
        my $source_range_start = $2;
        my $range_length = $3;
        my %map_hash = (
            source_min => $source_range_start,
            source_max => ($source_range_start + $range_length - 1),
            destination_start => $destination_range_start,
        );
        push @{$current_map}, \%map_hash;
    }
}

my $minimum_location = 0;

sub get_location
{
    my $seed = shift;
    # print "Beginning work on seed $seed.\n";
    my $soil = get_mapped_value (\@seed_to_soil_map, $seed);
    # print "Seed number $seed corresponds to soil number $soil.\n";
    my $fertilizer = get_mapped_value (\@soil_to_fertilizer_map, $soil);
    my $water = get_mapped_value (\@fertilizer_to_water_map, $fertilizer);
    my $light = get_mapped_value (\@water_to_light_map, $water);
    my $temperature = get_mapped_value (\@light_to_temperature_map, $light);
    my $humidity = get_mapped_value (\@temperature_to_humidity_map, $temperature);
    my $location = get_mapped_value (\@humidity_to_location_map, $humidity);
    print "Seed $seed, soil $soil, fertilizer $fertilizer, water $water, light $light, temperature $temperature, humidity $humidity, location $location.\n";
    return $location;
}

$| = 1;

print "Working on individual seeds. Seed count: $#seeds\n";
foreach my $seed (@seeds)
{
    my $location = get_location ($seed);
    if ($seed == $seeds[0])
    {
        $minimum_location = $location;
    }
    else
    {
        if ($location < $minimum_location)
        {
            $minimum_location = $location;
        }
    }
}

print "Done working on individual seeds.\n";
print "Constructing seed ranges...\n";
print "Sometimes brute force and manual iteration can work... I told you my code was ugly.\n";
my $minimum_location_for_ranges = 0;
my $seed_number_for_minimum = 0;
my $i_for_minimum_location = 0;
my $j_for_minimum_location = 0;
my $first_iteration = 1;
my $min_i = 0;
my $max_i = 0;
my $j_factor = 0.001;
my $center_j = 91747254;
for (my $i = 0; $i <= $max_i; $i += 2)
{
    my $initial_seed_number = $seeds[$i];
    my $seed_count = $seeds[$i + 1];
    print "Number of seeds: $seed_count\n";
    my $min_j = $center_j - int(10 * $j_factor * sqrt($seed_count));
    my $max_j = $center_j + int(10 * $j_factor * sqrt($seed_count));
    for (my $j = $min_j; $j < $max_j; $j += 1 )
    # int($j_factor * sqrt($seed_count)))
    {
        print "I: $i / $#seeds, J: $j / $seed_count\n";
        my $current_seed_number = $initial_seed_number + $j;
        my $location = get_location ($current_seed_number);
        if ($first_iteration)
        {
            $first_iteration = 0;
            $minimum_location_for_ranges = $location;
            $seed_number_for_minimum = $current_seed_number;
            $i_for_minimum_location = $i;
            $j_for_minimum_location = $j;
        }
        else
        {
            if ($location < $minimum_location_for_ranges)
            {
                $minimum_location_for_ranges = $location;
                $seed_number_for_minimum = $current_seed_number;
                $i_for_minimum_location = $i;
                $j_for_minimum_location = $j;
            }
        }
    }
}



print "Done working on seeds as ranges.\n";

print "Minimum location is: $minimum_location\n";
print "Minimum location for ranges is: $minimum_location_for_ranges\n";
print "Seed number for minimum location for ranges is: $seed_number_for_minimum\n";
print "I for minimum location: $i_for_minimum_location\n";
print "J for minimum location: $j_for_minimum_location\n";
print "J interval: " . int($j_factor * sqrt($seeds[($i_for_minimum_location + 1)])) . "\n";