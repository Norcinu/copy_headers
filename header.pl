#!/usr/bin/perl 


use strict;
use warnings;
use Cwd;

use constant false => 0;
use constant true  => 1;

my %feature_values = (97,"crab3", 115, "wonga3");

my $outcomes = "outcomes.h";

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
                print $full_path, "\n";                
                push(@headers, $full_path) if (-f $full_path);
            }    
        }
        
        print "number of header files is ", 0+@headers, "\n"; 
        
        if (length(@headers) == 0) {
            print "Empty directory listing. Find me some header files
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
    
    while (<FILE>) {
        print $_, "\n";
        print $counter++, "\n";
    }
    close FILE or die $!;
    close OUTC_FILE or die $!;
}

sub header_line_count($) {
    my $count = 0;
    return $count;
}

my @all_files = &parse_directory($ARGV[0]);
print "key 97 is ", $feature_values{97}, "\n";
&parse_file($all_files[2]);
