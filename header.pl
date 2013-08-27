#!/usr/bin/perl 

=pod
    Program to parse a folder of header files relating to the games outcome tables. Merges result into one outcome.h file.
    Also outputs the relevant data for GameAllowEvent.cpp.
=cut

use strict;
use warnings;
use Cwd;

use constant false => 0;
use constant true  => 1;

my %feature_values = (97,"crab3", 115, "lobster3", 116, "lobster4",
    117, "lobster5");

my $outcomes = "outcomes.h";
my @win_values;
my $allow_event_cast = "(unsigned char *)" # concat this with the filename

# outcomes_180 is used twice, once for £1.80 and once for wonga4
sub parse_directory($) {
    my $start_dir = $_[0];
    printf $start_dir, "\n";
    my @headers;
    
    if (-d $start_dir) {
        my $index = substr($start_dir, -1, 1);

        if ($index ne "/") {
            $start_dir .= "/";
        }
    
        chdir $start_dir or die "Cannot chdir to $start_dir.\n";
              
        opendir(DIR, $start_dir) or die "Cannot open the directory:
            $start_dir.\n";

        while (my $file = readdir(DIR)) {
            next if ($file =~ m/^\./);

            my $full_path = $start_dir . $file;
          

            if (&check_extension($full_path)) {
                #print $full_path, "\n";                
                push(@headers, $full_path) if (-f $full_path);
            }    
        }
        
        print "number of header files is ", 0+@headers, "\n"; 
        
        if (length(@headers) == 0) {
            print "Empty directory listing. Pass me some header files
                please.\n";
            return;
        }
                
        closedir(DIR);
    }
    return (@headers);
}

sub check_extension($) {
    my $file_name = $_[0];
    if ($file_name =~ /.h/) {
        return true;
    } else {
        return false;
    }
}

sub parse_file($) {
    my $file = $_[0];
    open FILE, "<$file" or die $!;
    open OUTC_FILE, ">>$outcomes" or die $!;
    my $counter = 1;
    my @lines = <FILE>; 
    my $file_counter = 0+@lines;
    push @win_values, $file_counter;

    for (@lines) {
        s/L5_Outcome_0+/outcomes_/; 
        if ($counter == 1) {
            $file_counter--;
            s/\[(\d+)\]/[$file_counter]/;
        }
        print OUTC_FILE $_;
        $counter++;
    }

    print OUTC_FILE "\n\n";    
    close FILE or die $!;
    close OUTC_FILE or die $!;
}

sub write_game_allow_event($) {
    
}

my @all_files = &parse_directory($ARGV[0]);
#print "key 97 is ", $feature_values{97}, "\n";

#for my $index (@all_files) {
for (my $i = 0; $i < 0+@all_files; $i++) {
    &parse_file($all_files[$i]);
}

#&parse_file($all_files[2]);


