#!/usr/bin/perl -w

# Have you got an interesting GenNet run?
# Back up your data effortlessly with this amazing script.

use Getopt::Std;
use Tie::File;
use Data::Dumper;
use File::Basename;
use strict;


# make directories to store data and get file names
my ($mydir,$datafile,$infofile,$pyfile,$figfile) = get_file_names();
my $back = "DATA";

# backup the important files
`cp -f $back/$datafile $mydir`;
`cp -f $back/$infofile $mydir`;
`cp -f $back/$figfile $mydir` if (-e "$back/$figfile");
#`cp -f $pyfile $mydir`;

println("Copied: \n\t$datafile\n\t$infofile\n\t$figfile\n\t$pyfile\nto:\n\t$mydir");

print "\n Would you like to edit the comment file? [y/n]: ";
my $choice = <STDIN>;
if ($choice =~ /y/) {
    #println("my dir: $mydir");
    #println("my info: $infofile");
    system("vi $mydir/$infofile");
} else {
    #println("not right: >$choice< and >" . $choice . "<");
}



sub get_file_names { 
    
    #get the local time
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);

    #construct the date string
    my @abbr = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );
    if ($mday < 10) { $mday = '0' . $mday; }
    my $date = $abbr[$mon] . $mday;

    #make sure everything has a leading 0
    if ($hour < 10) { $hour = '0' . $hour; }
    if ($min < 10)  { $min = '0' . $min; }
    if ($sec < 10) { $sec = '0' . $sec; }

    #make time string
    my $time = $hour . ":" .  $min . ":" . $sec;

    #make the backup directory
    my $back = "DATA/saved";
    mkdir ("$back") unless (-e "$back");
    #make the day's directory
    mkdir ("$back/$date") unless (-e "$back/$date");
    #make the time's  directory
    mkdir ("$back/$date/$time") unless (-e "$back/$date/$time");

    # construct the data file names
    $year = sprintf("%02d", $year % 100);
    my $datfile = "GenNet_" . $abbr[$mon] . "_" . $mday . "_" . $year . "_A1.dat";
    my $infofile = "GenNet_" . $abbr[$mon] . "_" . $mday . "_" . $year . "_A1.info";
    my $figfile = "GenNet_" . $abbr[$mon] . "_" . $mday . "_" . $year . "_A1.fig";
    my $pyfile = "sparse.py";
    
    # return data dir and 3 file names
    return ("$back/$date/$time", $datfile, $infofile, $pyfile, $figfile);
}

sub println {
    foreach(@_) { print };
    print "\n";
}
