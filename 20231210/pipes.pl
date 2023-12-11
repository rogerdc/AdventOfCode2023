#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

# my $data_file_name = "sampledata.txt";
# my $data_file_name = "sampledata2.txt";
my $data_file_name = "data.txt";

open (my $data, "<", $data_file_name) or die "Cannot open < $data_file_name: $!";

my @maze;
my $start_row;
my $start_column;
my $maze_row_count = 0;
my @maze_lines;

# 2-D array of pipes in the maze. Top left is [0][0]. Row, Column.
# Each element is a hash with the available connections, N, E, W, S as keys. 
# 1, 0 as values for whether there is a way out of that pipe in that direction.
# Find S. It should have two connections incoming. (it does, main data has E and S).
# Sample data does too. 

# Round 1: Walk the path from S to S, count the steps, divide by 2. 

while (my $line = readline($data))
{
    chomp $line;
    push @maze_lines, $line;
    my @pipes = split //, $line;
    my @columns;
    for (my $i = 0; $i <= $#pipes; $i++)
    {
        my $pipe = {
            n => 0,
            e => 0,
            s => 0,
            w => 0,
        };
        # print "Found a pipe: $pipes[$i]\n";
        if ($pipes[$i] eq "|")
        {
            $pipe->{n} = 1;
            $pipe->{s} = 1;
        }
        elsif ($pipes[$i] eq "-")
        {
            $pipe->{e} = 1;
            $pipe->{w} = 1;
        }
        elsif ($pipes[$i] eq "L")
        {
            $pipe->{n} = 1;
            $pipe->{e} = 1;
        }
        elsif ($pipes[$i] eq "J")
        {
            $pipe->{n} = 1;
            $pipe->{w} = 1;
        }
        elsif ($pipes[$i] eq "7")
        {
            $pipe->{s} = 1;
            $pipe->{w} = 1;
        }
        elsif ($pipes[$i] eq "F")
        {
            $pipe->{e} = 1;
            $pipe->{s} = 1;
        }
        elsif ($pipes[$i] eq "S")
        {
            $start_row = $maze_row_count;
            $start_column = $i;
            if ($data_file_name eq "sampledata2.txt")
            {
                $pipe->{w} = 1;
            }
            else
            {
                $pipe->{e} = 1;
            }
            $pipe->{s} = 1;
            print "Found start location: Row " . ($start_row + 1) . " column " . ($start_column + 1) . "\n";
        }
        push @columns, $pipe;
    }
    push @maze, \@columns;
    $maze_row_count++;
}

my $current_row = $start_row;
my $current_column = $start_column + 1;
my $incoming_direction = 'e';
my $backtrack_direction = 'w';
my $step_count = 1;

if ($data_file_name eq "sampledata2.txt")
{
    $current_column = $start_column - 1;
    $incoming_direction = 'w';
    $backtrack_direction = 'e';
}

my @visited;

push @visited, [$start_row, $start_column];

while (($current_row != $start_row) || ($current_column != $start_column))
{
    push @visited, [$current_row, $current_column];
    print "Visited [$current_row, $current_column]\n";
    my $next_direction;
    if ($maze[$current_row][$current_column]->{n} && ($backtrack_direction ne 'n'))
    {
        $next_direction = 'n';
    }
    elsif ($maze[$current_row][$current_column]->{e} && ($backtrack_direction ne 'e'))
    {
        $next_direction = 'e';
    }
    elsif ($maze[$current_row][$current_column]->{w} && ($backtrack_direction ne 'w'))
    {
        $next_direction = 'w';
    }
    elsif ($maze[$current_row][$current_column]->{s} && ($backtrack_direction ne 's'))
    {
        $next_direction = 's';
    }
    else
    {
        die "Cannot figure out next direction from row $current_row column $current_column incoming direction $incoming_direction backtrack direction $backtrack_direction. Pipe block: \n" . Dumper($maze[$current_row][$current_column]);
    }
    if ($next_direction eq 'n')
    {
        $current_row--;
        $incoming_direction = 'n';
        $backtrack_direction = 's';
    }
    elsif ($next_direction eq 'e')
    {
        $current_column++;
        $incoming_direction = 'e';
        $backtrack_direction = 'w';
    }
    elsif ($next_direction eq 's')
    {
        $current_row++;
        $incoming_direction = 's';
        $backtrack_direction = 'n';
    }
    elsif ($next_direction eq 'w')
    {
        $current_column--;
        $incoming_direction = 'w';
        $backtrack_direction = 'e';
    }
    if (
        ($current_row < 0)
        || ($current_row > $#maze)
        || ($current_column < 0)
        || ($current_column > $#{@maze[$current_row]})
    )
    {
        die "Fell off the edge of the maze. Current row: $current_row Current column: $current_column.";
    }
    $step_count++;
}

# $step_count++;

print "Took $step_count steps to traverse the maze. The maximum distance from the start position is: " . ($step_count / 2) .".\n";

print "Calculating area inside path...\n";

print "Modifying maze lines to show path.\n";

my @modified_maze_lines;

for (my $i = 0; $i <= $#maze_lines; $i++)
{
    my @maze_line = split //, $maze_lines[$i];
    foreach my $visit (@visited)
    {
        if ($visit->[0] == $i)
        {
            if ($maze_line[$visit->[1]] eq "J")
            {
                $maze_line[$visit->[1]] = "V";
            }
            elsif ($maze_line[$visit->[1]] eq "L")
            {
                $maze_line[$visit->[1]] = "V";
            }
            elsif ($maze_line[$visit->[1]] eq "|")
            {
                $maze_line[$visit->[1]] = "V";
            }
            else
            {
                $maze_line[$visit->[1]] = "H";
            }
        }
    }
    push @modified_maze_lines, join('', (@maze_line));
    print join('', (@maze_line)) . "\n";
}

my $enclosed = 0;

NEXTLINE: for (my $i = 0; $i <= ($#modified_maze_lines); $i++)
{
    print "Unmodified mazeline: $maze_lines[$i]\n";
    print "After modification:  $modified_maze_lines[$i]\n";
    my $is_inside = 0;
    my $v_count = 0;
    $modified_maze_lines[$i] =~ s/H//g;
    my @line = split //, $modified_maze_lines[$i];
    for (my $j = 0; $j <= $#line; $j++)
    {
        print "\n";
        print "Maze line index $i: $modified_maze_lines[$i]\n";
        print "j position         " . (' ' x $j) . "^\n";
        print "J is $j\n";
        print "is_inside is: $is_inside\n";
        print "V count is: $v_count\n";
        print "V count % 2 is: " . ($v_count % 2) . "\n";
        print "Character is: $line[$j]\n";
        print "enclosed is: $enclosed\n";
        if ($line[$j] eq "V")
        {
            $is_inside = ($is_inside xor 1);
            $v_count++;
            print "v count increased, is now: $v_count\n";
            print "is_inside flipped, is now: $is_inside\n";
        }
        elsif ($is_inside)
        {
            $enclosed++;
            print "Enclosed incremented, is now: $enclosed\n";
        }
    }
    # print "After modification:  $modified_maze_lines[$i]\n";
}

print "There are $enclosed tiles enclosed by the path.\n";