#!/usr/bin/env perl

use POSIX;
use Getopt::Long qw(:config auto_abbrev);

my ($optCantor, $optSzudzik, $optHelp);

GetOptions ('cantor'  => \$optCantor,
            'szudzik' => \$optSzudzik,
            'help'    => \$optHelp) or usage();
usage() if $optHelp || ($optCantor && $optSzudzik);

$optSzudzik = 1 unless $optCantor || $optSzudzik;

while (my $line = <>) {
    if ($line =~ /^\s*(\d+)\s+(\d+)\s*$/) {
        my($x, $y) = ($1, $2);
        my $z = ($optSzudzik) ? szudzik($x, $y) : cantor($x, $y);
        print "$z\n";
    } elsif ($line =~ /^\s*(\d+)\s*$/) {
        my $z = $1;
        my($x, $y) = ($optSzudzik) ? inverseSzudzik($z) : inverseCantor($z);
        print "$x $y\n";
    }
}

# Cantor Pairing
#################
sub cantor {
    my ($x, $y) = @_;
    return ($x + $y)*($x + $y + 1)/2 + $y;
}

sub inverseCantor {
    my $z = shift;
    my $w = floor((sqrt(8*$z + 1) - 1)/2);
    my $t = ($w*$w + $w)/2;
    my $y = int($z - $t);
    my $x = int($w - $y);
    return ($x, $y);
}

# Szudzik Pairing
#################
sub szudzik {
    my ($x, $y) = @_;
    return $x >= $y ? $x * $x + $x + $y : $x + $y * $y;
}

sub inverseSzudzik {
    my $z = shift;
    my ($x, $y);
    my $fz = floor(sqrt($z));
    my $fz2 = $fz * $fz;
    if ($z - $fz2 < $fz) {
        $x = int($z - $fz2);
        $y = int($fz);
    } else {
        $x = int($fz);
        $y = int($z - $fz2 - $fz);
    }
    return ($x, $y);
}

sub usage {
    my $bname = substr($0, rindex($0, "/") + 1);
    print STDERR "$bname [-cantor|-szudzik] stdin|file  # -szudzik is default\n\n";
    print STDERR "Given pairs of input: output the pairing function value (using cantor or szudzik)\n";
    print STDERR "Given single inputs: output the original pairs\n";
    print STDERR "\nExample:\n\$ cat /tmp/data\n 4    5\n 3    9\n 12  300\n\n";
    print STDERR "\$ pairing.pl /tmp/data\n29\n84\n90012\n\n";
    print STDERR "\$ pairing.pl /tmp/data | pairing.pl\n4 5\n3 9\n12 300\n";

    exit 1;
}
