#!/usr/bin/env perl

#
# General column cutter
# 
# dwf -- initial
# Fri Feb 22 09:59:58 MST 2013

use strict;
use Getopt::Long;
use FileHandle;
use open qw/:std :encoding(UTF-8)/;
use feature 'unicode_strings';

my ($statfile, @col, $delim, $outdelim, @fields, $preserve, $quiet);
$delim = ' ';
$outdelim = undef;
my $re=1;
my $label=1;
GetOptions('statfile=s' => \$statfile,
           'col=s@'     => \@col,
           're!'        => \$re,
           'label!'     => \$label,
           'delim=s'    => \$delim,
           'outdelim=s' => \$outdelim,
           'field=s@'   => \@fields,
           'preserve'   => \$preserve,
           'quiet'      => \$quiet) or usage();
usage() if @col == 0 && @fields == 0;
$outdelim = $delim unless defined $outdelim;
$outdelim = "\t" if $outdelim eq '\t';

unless ($statfile) {
    $statfile = (@ARGV) ? shift : '-';
}

my $fh = new FileHandle($statfile) or die "Can't read file \"$statfile\"\n";
binmode $fh, ":encoding(UTF-8)";
my $statfileHdr = $fh->getline();
$statfileHdr =~ s/\r?\n$//;
my @hdrInfo;

# Find the column headers
my %seen;
foreach my $field (@fields) {
    my %flds;
    foreach my $f (split(/,/, $field)) {
        if ($f =~ /^(\d+)-(\d+)$/) {
            foreach my $range ($1 .. $2) {
                $flds{$range} = 1;
            }
        } else {
            $flds{$f} = 1;
        }
    }

    my $found = 0;
    my $i = 0;
    my @labels = $delim eq ' ' ? split(' ', $statfileHdr) : split(/$delim/, $statfileHdr);
    foreach my $lab (@labels) {
        if (exists $flds{$i+1}) {
            unless (exists $seen{$i}) { # avoid pushing dups
                push(@hdrInfo, { idx => $i, label => $lab });
                $seen{$i} = 1;
            }
            $found = 1;
        }
        $i++;
    }
    if (!$found) {
        exit 1 if $quiet;
        die "No match for field pattern \"$field\"\n";
    }
}


foreach my $colPattern (@col) {
    my $found = 0;
    my $i = 0;
    my @labels = $delim eq ' ' ? split(' ', $statfileHdr) : split(/$delim/, $statfileHdr);
    foreach my $lab (@labels) {
        if (($re && $lab =~ /$colPattern/) || ($lab eq $colPattern)) {
            unless (exists $seen{$i}) { # avoid pushing dups
                push(@hdrInfo, { idx => $i, label => $lab });
                $seen{$i} = 1;
            }
            $found = 1;
        }
        $i++;
    }
    if (!$found) {
        exit 1 if $quiet;
        die "No match for column header pattern \"$colPattern\"\n";
    }
}

# Order indicies ascending numeric if original statfile order is to be preserved 
if ($preserve) {
    @hdrInfo = sort { $a->{idx} <=> $b->{idx} } @hdrInfo;
}


# Found 'em, print the columns
if ($label) {
    my @columns;
    foreach my $hdr (@hdrInfo) {
        push(@columns, $hdr->{label});
    }
    print join($outdelim, @columns),"\n";
}

while (my $line = $fh->getline()) {
    $line =~ s/\r?\n$//;
    my @flds = $delim eq ' ' ? split(' ', $line) : split(/$delim/, $line);
    my @values;
    foreach my $hdr (@hdrInfo) {
        if ($hdr->{idx} > $#flds) {
            push(@values, '*');
        } else {
            push(@values, $flds[$hdr->{idx}]);
        }
    }
    print join($outdelim, @values),"\n";
}



sub usage {
    my $bname = substr($0, rindex($0, "/") + 1);
    print STDERR "$bname -statfile file.stats -field range -col RE [-delim str] [-outdelim str] [-(no)re] [-(no)label] [-preserve] [-quiet]\n";
    print STDERR "\t-statfile file.stats   stats file\n";
    print STDERR "\t-field range           column # or range\n";
    print STDERR "\t-col STR               string matching column label in the stats file\n";
    print STDERR "\t-re                    treat -col STR as regular expression (default)\n";
    print STDERR "\t-label                 output the column label (default)\n";
    print STDERR "\t-delim delim           delimiter to split fields on (defaults to tab)\n";
    print STDERR "\t-outdelim delim        output delimiter (defaults to delim) [use '\\t' for tab]\n";
    print STDERR "\t-preserve              output selected columns in original statfile order\n";
    print STDERR "\t-quiet                 die silently on error\n";
    print STDERR "Examples:\n\n";
    print STDERR "\tGiven the following tab separated input in file 'test.stats':\n\n";
    print STDERR "\t\tgrade Predicted id\n";
    print STDERR "\t\t2     3         1\n";
    print STDERR "\t\t1     2         2\n";
    print STDERR "\t\t1     1         3\n\n";
    print STDERR "\t# output columns 'grade' and 'Predicted'\n";
    print STDERR "\tcutcol.pl -col grade -col Predicted test.stats\n";
    print STDERR "\tcutcol.pl -field 1 -field 2 test.stats\n\n";
    print STDERR "\t# output columns 'grade' and 'Predicted'\n";
    print STDERR "\tcutcol.pl -col gr -col Pre test.stats\n";
    print STDERR "\tcutcol.pl -f 1-2 test.stats\n\n";
    print STDERR "\t# output columns 'Predicted' and 'grade'\n";
    print STDERR "\tcutcol.pl -col 'ed\$' -col 'de\$' test.stats\n";
    print STDERR "\tcutcol.pl -f 2 -f 1 test.stats\n\n";
    print STDERR "\t# output columns 'Predicted' and 'id'\n";
    print STDERR "\tcutcol.pl -col '(?i)pre' -col 'id' test.stats\n\n";
    print STDERR "\t# output all columns comma separated\n";
    print STDERR "\tcutcol.pl -col . -outdelim=, test.stats\n\n";
    print STDERR "\t# output columns 'id' and 'grade'\n";
    print STDERR "\tcutcol.pl -col id -col grade test.stats\n\n";
    print STDERR "\t# output columns 'grade' and 'id'\n";
    print STDERR "\tcutcol.pl -preserve -col id -col grade test.stats\n\n";
    print STDERR "\t# output all columns comma separated, then convert back to tab\n";
    print STDERR "\tcutcol.pl -col=. -outdelim=, -statfile=test.stats | cutcol.pl -delim=, -col=. -outdelim='\\t' -\n\n";
    exit 1;
}
