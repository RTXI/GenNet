#!/usr/bin/perl -w

# Sweep a parameter range and save information about every run

use Getopt::Std;
use Tie::File;
use Data::Dumper;
use File::Basename;
use strict;

die "Usage: netfile\n" if ($#ARGV != 0);

# get input net file
my $netfile = shift(@ARGV);


# make directories to store data
my ($mydir,$datafile) = make_directories("DATA/ParamSweeps");


# read input file as array and find sweep start,inc,end
tie my @net, 'Tie::File', $netfile  or die "Error: Can't Tie $netfile\n";
my ($pos,$line) = get_sweep_line(@net);
println("1. ", $pos, ': ', $line);


my @info = get_sweep_info($line);
#print "2. ", $start, ', ', $inc, ', ', $end, "\n";

my ($param, $start, $inc, $end);
if (scalar(@info) == 4) {
    ($param,$start,$inc,$end) = @info;
} elsif (scalar(@info) == 3) {
    ($start,$inc,$end) = @info;
}
    

# backup original nets file and copy to data dir
my ($netname,$netpath) = fileparse($netfile);
my $filebak = $netfile . ".bak";
`cp -f $netfile $filebak`;
`cp -f $netfile $mydir/$netname`;

# run for each param value, including the endpoint
for(my $i = $start; $i <= $end; $i += $inc) {

    # make sure we have 1 sig. digit to ensure consistent naming
    my $replace = sprintf("%.1f", $i);

    # replace sweep info in the file with one value
    replace_sweep_info($pos,$line,\@net,$replace,$param);

    println("\nRunning simulation for param value $replace");

    # run the sims
    `gn $netfile`;

    # copy data correctly
    my $newfilename = $datafile;
    $newfilename =~ s#A1#$replace#;
    println($newfilename);
    `cp -f DATA/$datafile $mydir/$newfilename`;

    # copy intermediate netfiles (mostly for debugging)
    # 
    my $tmpnetfile;
    if ($param) {
        $tmpnetfile = $netname . "_" . $param . "_" . $i;
    } else {
        $tmpnetfile = $netname . "_" . $i;
    }

    `cp -f $netfile $mydir/$tmpnetfile`;
}

# release the file
untie @net;

# restore the original data file
`cp -f $filebak $netfile`;
`rm -f $filebak`;

println("Files copied to $mydir");


## make a matlab style list of values
sub make_list {

    my $start = shift(@_);
    my $inc = shift(@_);
    my $end = shift(@_);

    my @res = (); 
    for (my $i = $start; $i <= $end; $i += $inc) {
        push(@res, $i);
    }   
    return @res;
}

## parse out sweep info from net file
sub get_sweep_info {

    my ($line) = shift @_;

    # match the optional param, start, inc and end of the sweep
    $line =~ /\[(\w*):?(.+):(.+):(.+)\]/;


    # make sure numbers are in range
    die "Error: Sweep invalid: [$2:$3:$4]\n" if ($4 < $2 or $3 > ($4 - $2));

    # return a variable amount of stuff depending on if we have a param
    unless ($1) {
        println ("no paramter");
        println("$2 - $3 - $4");
        return ($2,$3,$4);
    } else {
        println ("parameter");
        println("$1 - $2 - $3 - $4");
        return ($1,$2,$3,$4);
    }
}

## find line and line number of sweep line
sub get_sweep_line {
    my $ind = 0;
    foreach (@_) {
        # match syntax of sweep [0:0:0]
        # if(/\[[\-\.\d]+:[\-\.\d]+:[\-\.\d]+\]/) {
        if(/\[.+\]/) {
            return ($ind,$_);
        } else {
            $ind++;
        }
    }
    die "Error: Sweep syntax [0:0:0] not found\n";
}

## replace sweep info line in the file with one value
sub replace_sweep_info {

    #position in file, existing line, ref to file array, repalcement value
    my ($pos,$ln,$fileref,$val,$p) = @_;  

    #print Dumper($fileref);
    # substitute the value in for the sweep syntax in the file
    if ($p) {
        $ln =~ s#\[.+\]#$p=$val#;
    } else {
        $ln =~ s#\[.+\]#$val#;
    }

    #print "line is: $ln\n";
    @{$fileref}[$pos] = $ln;
    # print Dumper (@f);
}

sub make_directories { 
    #backupsrdirectory name
    my $back = "DATA/ParamSweeps";

    #get the local time
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);

    #construct the date string
    my @abbr = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );
    my $date = $abbr[$mon] . $mday;

    #make sure everything has a leading 0
    if ($hour < 10) { $hour = '0' . $hour; }
    if ($min < 10)  { $min = '0' . $min; }
    if ($sec < 10) { $sec = '0' . $sec; }

    #make time string
    my $time = $hour . ":" .  $min . ":" . $sec;

    #make the backup directory
    mkdir ("$back") unless (-e "$back");
##make the day's directory
    mkdir ("$back/$date") unless (-e "$back/$date");
    #make the time's  directory
    mkdir ("$back/$date/$time") unless (-e "$back/$date/$time");

# construct the data file name
    $year = sprintf("%02d", $year % 100);
    my $datfile = "GenNet_" . $abbr[$mon] . "_" . $mday . "_" . $year . "_A1.dat";
    return ("$back/$date/$time", $datfile);
}

sub println {
    foreach(@_) { print };
    print "\n";
}
