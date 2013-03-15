#!/usr/bin/env perl

#
# Squeezebox command line utilities

use strict;
use FileHandle;
use IO::Socket::INET;
use URI::Escape;
use File::Basename;
use Term::ANSIColor qw/:constants/;
use Getopt::Long qw(:config auto_abbrev);
use Cwd qw(abs_path);

#use open qw/:std :encoding(UTF-8)/;
use feature 'unicode_strings';

my $PHYSICAL_MUSIC_LOCATION = '/Volumes/EMusic/Songs';
my $LOGICAL_MUSIC_LOCATION = '/music';

my(@optAdd, @optPlay, $optNext, $optList, $optRandom, $optSize, $optPause, $optPlayers,
   $optPower, $optInfo, $optVolume, $optClear, $optID, $optMI, $optHelp);
$optSize = 10;
$optID = 0;
$optVolume = undef;
$optPower = undef;
GetOptions('add=s{,}'  => \@optAdd,
           'play=s{,}' => \@optPlay,
           'next:1'    => \$optNext,
           'list'      => \$optList,
           'random=s'  => \$optRandom,
           'size=i'    => \$optSize,
           'pause'     => \$optPause,
           'players'   => \$optPlayers,
           'power:s'   => \$optPower,
           'info'      => \$optInfo,
           'volume:s'  => \$optVolume,
           'clear'     => \$optClear,
           'id=s'      => \$optID,
           'mi'        => \$optMI,
           'help'      => \$optHelp) or die usage();
usage() if $optHelp;

my $host = "localhost";
my $port = 9090;

my $socket = IO::Socket::INET->new(PeerAddr => $host,
                                   PeerPort => $port,
                                   Proto    => 'tcp',
                                   Timeout  => 5) or die "$!";
binmode $socket, ':encoding(UTF-8)';

# password protected
#sendcmd($socket, 'login username password');

my $playerID = (split(' ', sendcmd($socket, "player id $optID ?")))[-1];
if ($playerID eq "") {
    die "Invalid player id: $optID\n";
}
my ($playerName) = sendcmd($socket, "player name $playerID ?") =~ /^player name $playerID (.*)/;
my $PLR = { sock => $socket, id => $playerID, name => $playerName };


if (defined $optClear) {
    clear_cmd($PLR);
}

if ($optNext) {
    my $result = next_cmd($PLR, $optNext);
    print $result;
} elsif ($optInfo) {
    print "Slimserver Version: " . version_cmd($PLR) . "\n\n";
    print "Players:\n";
    print players_cmd($PLR);
    print "Library:\n";
    print library_cmd($PLR) . "\n";
    print power_cmd($PLR);
    print volume_cmd($PLR) . "\n";
} elsif ($optList) {
    my $result = list_cmd($PLR);
    print $result;
} elsif ($optPause) {
    my $result = pause_cmd($PLR);
    print $result;
} elsif ($optPlayers) {
    my $result = players_cmd($PLR);
    print $result;
} elsif (defined $optVolume) {
    my $result = volume_cmd($PLR, $optVolume);
    print $result;
} elsif (defined $optPower) {
    my $result = power_cmd($PLR, $optPower);
    print $result;
} elsif (@optPlay) {
    play_cmd($PLR, \@optPlay);
    print list_cmd($PLR);
} elsif (@optAdd) {
    add_cmd($PLR, \@optAdd);
    print list_cmd($PLR);
} elsif ($optRandom) {
    random_cmd($PLR, $optRandom, $optSize);
    print list_cmd($PLR);
} elsif ($optMI) {
    my $path = sendcmd($PLR->{sock}, $PLR->{id} . " path ?");
    if ($path =~ m,file://,) {
        chop($path);
        $path =~ s,.*file://,,;
        $path = quotemeta($path);
        $path =~ s,\\/,/,g;
        $path =~ s,\\\.,.,g;
        print $PLR->{name} . ": $path\n";
        system("mi $path");
    }
}

exit 0;

################################################################

sub sendcmd {
    my ($socket, $cmd) = @_;
    print $socket $cmd . "\n";
    my $response = $socket->getline();
    while ($response =~ /%[0-9A-F]{2}/) {
        $response = uri_unescape($response);
    }
    return $response;
}

################################################################

sub next_cmd {
    my ($sq, $n) = @_;
    if ($n > 0) {
        $n = "+$n";
    }
    return sendcmd($sq->{sock}, $sq->{id} . " playlist index $n");
}

################################################################

sub pause_cmd {
    my $sq = shift;
    return $sq->{name} . ": " . sendcmd($sq->{sock}, $sq->{id} . " pause");
}

################################################################

sub version_cmd {
    my $sq = shift;
    my $result = (split(' ', sendcmd($sq->{sock}, $sq->{id} . " version ?")))[-1];
    return $result;
}

################################################################

sub library_cmd {
    my $sq = shift;
    my $totalArtists = (split(' ', sendcmd($sq->{sock}, $sq->{id} . " info total artists ?")))[-1];
    my $totalAlbums = (split(' ', sendcmd($sq->{sock}, $sq->{id} . " info total albums ?")))[-1];
    my $totalSongs = (split(' ', sendcmd($sq->{sock}, $sq->{id} . " info total songs ?")))[-1];
    return "Artists: $totalArtists\nAlbums:  $totalAlbums\nSongs:   $totalSongs\n";
}

################################################################

sub clear_cmd {
    my $sq  = shift;
    sendcmd($sq->{sock}, $sq->{id} . " playlist clear");
}

sub play_cmd {
    my ($sq, $item) = @_;
    if (@$item) {
        clear_cmd($sq);
        add_cmd($sq, $item);
    }
}

sub add_cmd {
    my ($sq, $item) = @_;
    foreach my $f (@$item) {
        my $path = abs_path($f);
        $path =~ s,^$PHYSICAL_MUSIC_LOCATION,$LOGICAL_MUSIC_LOCATION,;
        next unless -f $path;
        $path = uri_escape_utf8($path);
        sendcmd($sq->{sock}, $sq->{id} . " playlist add $path");
    }
    sendcmd($sq->{sock}, $sq->{id} . " play");
}

sub random_cmd {
    my ($sq, $genres, $n) = @_;
    $genres =~ s/:/','/g;
    $genres = "'" . $genres . "'";
    my $cmd = "mysql -s -u slimserver slimserver -e \"
                  SELECT url FROM tracks
                    WHERE id IN (SELECT track FROM genre_track
                      WHERE genre IN (SELECT id FROM genres
                        WHERE name IN ($genres)))
                    ORDER BY RAND() LIMIT $n\"";
    my @items;
    my $fh = new FileHandle("$cmd |") or die "Can't execute MySQL cmd\n";
    while (my $track = $fh->getline()) {
        if ($track =~ m,^file://(.*),) {
            push(@items, uri_unescape($1));
        }
    }
    $fh->close();
    add_cmd($sq, \@items);
}

################################################################

sub power_cmd {
    my ($sq, $state) = @_;
    $state = "?" if $state eq "";
    if ($state eq 'on') {
        $state = 1;
    } elsif ($state eq 'off') {
        $state = 0;
    }
    $state = (split(' ', sendcmd($socket, "$playerID power $state")))[-1];
    $state = ($state == 1) ? "on" : "off";
    return $sq->{name} . " power is: $state\n";
}

################################################################

sub volume_cmd {
    my ($sq, $n) = @_;
    my ($vol) = sendcmd($sq->{sock}, $sq->{id} . " mixer volume ?") =~ /mixer volume (\d+\.?\d*)/;
    if ($n eq "") {
        return $sq->{name} . " current volume: $vol\n";
    }
    if ($n =~ /^[+-]/) {
        $vol += $n;
    } else {
        $vol = $n;
    }
    if ($vol > 100) {
        $vol = 100;
    } elsif ($vol < 0) {
        $vol = 0;
    }
    sendcmd($sq->{sock}, $sq->{id} . " mixer volume $vol");
    return $sq->{name} . " new volume: $vol\n";
}

################################################################

sub players_cmd {
    my $sq = shift;
    my $result = "";
    my ($playerCount) = sendcmd($sq->{sock}, "player count ?") =~ /^player count (\d+)/;
    for (my $playerIndex = 0; $playerIndex < $playerCount; $playerIndex++) {
        my $id = (split(' ', sendcmd($sq->{sock}, "player id $playerIndex ?")))[3];
        my $ip = (split(' ', sendcmd($sq->{sock}, "player ip $id ?")))[3];
        my ($name) = sendcmd($sq->{sock}, "player name $id ?") =~ /^player name $id (.*)/;
        my ($model) = sendcmd($sq->{sock}, "player model $id ?") =~ /^player model $id (.*)/;
        $result .= "player index: $playerIndex\n";
        $result .= "player id:    $id\n";
        $result .= "player ip:    $ip\n";
        $result .= "player name:  $name\n";
        $result .= "player model: $model\n\n";
    }
    return $result;
}

################################################################

sub list_cmd {
    my $sq = shift;

    my $count = (split(' ', sendcmd($sq->{sock}, $sq->{id} . " playlist tracks ?")))[-1];
    my $index = (split(' ', sendcmd($sq->{sock}, $sq->{id} . " playlist index ?")))[-1];
    my (@titles, @times, @albums, @artists);
    my ($titleLen, $timeLen, $albumLen, $artistLen) = (5,5,5,6);
    for (my $i=0; $i < $count; $i++) {
        chomp(my $title = sendcmd($sq->{sock}, $sq->{id} . " playlist title $i ?"));
        $title =~ s/$playerID playlist title $i //;
        push(@titles, $title);
        $titleLen = length($title) if length($title) > $titleLen;

        chomp(my $duration = sendcmd($sq->{sock}, $sq->{id} . " playlist duration $i ?"));
        $duration =~ s/$playerID playlist duration $i //;
        push(@times, sprintf("%2d:%02d",int($duration/60),$duration%60));

        chomp(my $album = sendcmd($sq->{sock}, $sq->{id} . " playlist album $i ?"));
        $album =~ s/$playerID playlist album $i //;
        push(@albums, $album);
        $albumLen = length($album) if length($album) > $albumLen;

        chomp(my $artist = sendcmd($sq->{sock}, $sq->{id} . " playlist artist $i ?"));
        $artist =~ s/$playerID playlist artist $i //;
        push(@artists, $artist);
        $artistLen = length($artist) if length($artist) > $artistLen;
    }

    $titleLen  += 2;
    $timeLen   += 2;
    $albumLen  += 2;
    $artistLen += 2;
    my $border = "+" . "-" x $titleLen . "+" . "-" x $timeLen . "+" . "-" x $albumLen . "+" . "-" x $artistLen . "+\n";
    my $result = "";
    for (my $i=0; $i < $count; $i++) {
        if ($i == 0) {
            $result .= $border;
            $result .= "|" . " Track"  . " " x ($titleLen  - length("Track")  - 1) . 
                       "|" . " Time"   . " " x ($timeLen   - length("Time")   - 1) . 
                       "|" . " Album"  . " " x ($albumLen  - length("Album")  - 1) . 
                       "|" . " Artist" . " " x ($artistLen - length("Artist") - 1) . "|\n";
            $result .= $border;
        }

        $result .= REVERSE if $i == $index;
        $result .= "| " . $titles[$i]  . " " x ($titleLen  - length($titles[$i])  - 1) . 
                   "| " . $times[$i]   . " " x ($timeLen   - length($times[$i])   - 1) . 
                   "| " . $albums[$i]  . " " x ($albumLen  - length($albums[$i])  - 1) . 
                   "| " . $artists[$i] . " " x ($artistLen - length($artists[$i]) - 1) . "|\n"; 
        $result .= RESET if $i == $index;

        if ($i+1 == $count) {
            $result .= $border;
        }
    }
    return $result;
}

################################################################

sub usage {
    my $bname = substr($0, rindex($0, "/") + 1);
    print STDERR "$bname [-player|-id] cmd [args]\n";
    print STDERR "  cmd:\n";
    print STDERR "    players                -- show information on known players\n";
    print STDERR "    info                   -- show summary of the music library and players\n";
    print STDERR "    clear                  -- clear current playlist\n";
    print STDERR "    add file|dir [...]     -- add content to the current playlist\n";
    print STDERR "    pl(ay) file|dir [...]  -- clear current playlist, then add content\n";
    print STDERR "    pa(use)                -- pause toggle\n";
    print STDERR "    po(wer) [on|off]       -- power query and control\n";
    print STDERR "    list                   -- show song/album/artist in the current playlist\n";
    print STDERR "    n(ext) [-#|+#]         -- jump +/- in playlist, default is +1\n";
    print STDERR "    v(olume) [-#|+#|#]     -- volume query, +/- adjust, or set\n";
    print STDERR "    r(andom) genre1:genre2 -- add random songs of type genre, default is 10 songs\n";
    print STDERR "    s(ize) #               -- size of random selection, default is 10\n";
    print STDERR "    mi                     -- run external \"mi\" utility on the current music file\n";
    exit 1;
}
