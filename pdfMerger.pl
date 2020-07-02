#!/usr/bin/perl
use strict;
use warnings;

# outputs usage message for program
sub UsageMessage {
        print "Usage: perl ", $0, " <filename>\n";
        print "\tfilename must be a file containing PDF's\n";
	return;
}

# returns if the string ends in .pdf
# returns 1 if does end in .pdf (true), 0 otherwise
sub isPDF {
	my ($name) = @_;
	my $position = index($name, ".pdf");
	if ($position <= 0) { return 0; }
	if (length($name)-4 == $position ) { return 1; }
	return 0;
}

# if there is no file specified or if there are too many files, exit with a usage message
if (not scalar @ARGV or scalar @ARGV > 1) { 
	UsageMessage;
	exit 1;
}

opendir my $directory, $ARGV[0] or die "Could not open '$ARGV[0]' for reading: $!\n";

my $firstPDF = '';
my $counter = 0;
while (my $file = readdir $directory) {	
	if (isPDF($file)) {
		if ($counter == 0) { 
			$firstPDF = $file; 
			$counter += 1;
		} else {
			# currently this only works if the program is in the same file as the pdfs
			if ($counter == 1) {
				system ("pdfunite '$firstPDF' '$file' ./new.pdf");
			} else {
				system ("pdfunite old.pdf '$file' ./new.pdf");
				system ("rm old.pdf");
			}
			system ("mv new.pdf old.pdf");
			$counter +=1;
		}		
	} else {
		if (not $file eq "." and not $file eq "..") {
			print "Unable to add ", $file, ". As it is not a pdf.\n";
		}
	}
}

system ("mv old.pdf compliedPDFs.pdf");
print "Merged ", $counter, " pdfs into file compliedPDFs.pdf\n";
