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

my $outcomes = "outcomes.h";
my @win_values;
my $allow_event_cast = "(unsigned char *)"; # concat this with the filename

sub parse_directory($) {
    my $start_dir = $_[0];
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
                push(@headers, $full_path) if (-f $full_path);
            }    
        }
               
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
    if ($file_name =~ /\.h/) {
        return true;
    } else {
        return false;
    }
}

sub parse_file {
    my $file = $_[0]; 
    my $op = $_[1];
    
    if ($op == 0) {
        print "op is zero\n";
        return;
    }
   
    open FILE, "<$file" or die $!;
    open OUTC_FILE, ">>$outcomes" or die $!;
    my $counter = 1;
    my @lines = <FILE>; 
    my $file_counter = 0+@lines;
    push @win_values, $file_counter;
     
    #splice(@lines, 0, 2) if ($lines[0] =~ /#include/);
    shift @lines if ($lines[0] =~ /\#include/);
    if ($op == 1) {
        for (@lines) {
            $_ = &parse_and_replace("outcome_0+","outcomes_", $file_counter, $counter);
            print OUTC_FILE $_;
            $counter++;
        }
    } elsif ($op == 2) {
        my ($feature_number) = $file =~ /_0(\d+)/;
        my $ftr_str_replacement = &select_which_feature($feature_number);
        for (@lines) {
            $_ = &parse_and_replace("outcome_[0-9]+", "outcomes_".
                &select_which_feature($feature_number), $file_counter, 
                $counter);
            print OUTC_FILE $_;
            $counter++;
        }
    }

    my $last_line = $lines[-1];
    if ($last_line =~ /},/) { 
        print OUTC_FILE "};\n\n";    
    } else {
        print OUTC_FILE "\n\n";
    }
    close FILE or die $!;
    close OUTC_FILE or die $!;
}

sub select_which_feature {
    if ($_[0] == 97) {
        return "crab3";
    } elsif ($_[0] == 115) {
        return "lobster3";
    } elsif ($_[0] == 116) {
        return "lobster4";
    } elsif ($_[0] == 117) {
        return "lobster5";
    } elsif ($_[0] == 131) {
        return "puffer3";
    } elsif ($_[0] == 132) {
        return "puffer4";
    } elsif ($_[0] == 133) {
        return "puffer5";
    } elsif ($_[0] == 147) {
        return "shell3";
    } elsif ($_[0] == 148) {
        return "shell4";
    } elsif ($_[0] == 149) {
        return "shell5";
    } elsif ($_[0] == 163) {
        return "starfish3";
    } elsif ($_[0] == 164) {
        return "starfish4";
    } elsif ($_[0] == 165) {
        return "starfish5";
    } elsif ($_[0] == 179) {
        return "wonga3";
    } elsif ($_[0] == 180) {
        return "wonga4";
    } elsif ($_[0] == 181) {
        return "wonga5";
    } else {
        return "";
    }
}

sub parse_and_replace {
    my $requirement_str = $_[0];
    my $replacement_str = $_[1];
    my $file_ctr = $_[2];
    my $final = "";

    s/$requirement_str/$replacement_str/;
    
    if ($_[3] == 2) {
        $file_ctr -= 3;
        s/\[(\d+)\]/[$file_ctr]/;
        
        open HEADER_INFO, ">>", "info.txt" or die $!;
        print HEADER_INFO $_;
        close HEADER_INFO;
    }

    return $_;
}

sub get_header_type {
    my $operation_type = 0;
    if ($ARGV[0] eq "-w") {
        $operation_type = 1;    
    } elsif ($ARGV[0] eq "-f") {
        $operation_type = 2;
    } 
    return $operation_type;
}

sub check_start_file_exist {
    my $win_path = $ARGV[1] . $outcomes;
    my $info_path = $ARGV[1] . "info.txt";

    if (-e $win_path) {
        print "Removing starting files.\n";
        unlink $win_path or warn "Could not unlink $win_path.\n";
        unlink $info_path or warn "Could not unlink $info_path\n";
    } else {
        print "$win_path does not exist... yet.\n"
    }
}

check_start_file_exist();
my @all_files = &parse_directory($ARGV[1]);
for (my $i = 0; $i < 0+@all_files; $i++) {
    &parse_file($all_files[$i], &get_header_type());
}

