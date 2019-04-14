
## Pairing

szudzik & cantor

```
pairing.pl [-cantor|-szudzik] stdin|file  # -szudzik is default

Given pairs of input: output the pairing function value (using cantor or szudzik)
Given single inputs: output the original pairs

Examples
--------
$ cat /tmp/data
 4    5
 3    9
 12  300

$ pairing.pl /tmp/data
29
84
90012

$ pairing.pl /tmp/data | pairing.pl
4 5
3 9
12 300
```

## ncol.py - Align data into padded columns
```
ncol.py cols [file|stdin]

$ cat data
one
two
three
four
five
six
seven
eight
nine
ten

$ ncol.py 3 data
one    two    three
four   five   six
seven  eight  nine
ten

$ ncol.py 5 < data
one  two    three  four  five
six  seven  eight  nine  ten

$ series 1 30 | ncol.py 7
1   2   3   4   5   6   7
8   9   10  11  12  13  14
15  16  17  18  19  20  21
22  23  24  25  26  27  28
29  30
```

## mi - Music Info
 
Utility to extract tag information from various music file formats or
display a pretty-printed album style summary from a directory or set of files

Examples
--------
```
$ mi --summary /music/a/AC-DC/Volts
                                AC/DC
                            Volts (1977)
                         Playing Time: 57:09

 1. Dirty Eyes ................................................ 3:21 
 2. Touch Too Much ............................................ 6:34 
 3. If You Want Blood (You've Got It) ......................... 4:26 
 4. Back Seat Confidential .................................... 5:23 
 5. Get It Hot ................................................ 4:15 
 6. Sin City .................................................. 4:53 
 7. She's Got Balls ........................................... 7:56 
 8. School Days ............................................... 5:21 
 9. It's A Long Way To The Top (If You Wanna Rock 'N' Roll) ... 5:16 
10. Ride On ................................................... 9:44 

$ mi "/music/b/Buddaheads/Howlin' At The Moon/01. Long Way Down.mp3" 
title:    Long Way Down
artist:   Buddaheads
album:    Howlin' At The Moon
genre:    Blues
year:     2004
track:    1
time:     5:16
vbr:      yes
encoder:  LAME3.97 
version:  ID3v2.3.0, ID3v1.1
bitrate:  270

$ mi "/music/Loseless/Donna The Buffalo/Rockin' In The Weary Land/01. Tides Of Time.flac" 
title:    Tides Of Time
artist:   Donna The Buffalo
album:    Rockin' In The Weary Land
genre:    Alternative Country
year:     1998
track:    01/12
time:     3:27
encoder:  flac --best
bitrate:  16 bits per sample @ 44100Hz

$ mi "/music/p/Paul Reddick & The Sidemen/Rattlebag/13. Smokehouse.ogg "
title:    Smokehouse
artist:   Paul Reddick & The Sidemen
album:    Rattlebag
genre:    Blues
year:     2001
track:    13
time:     2:54
encoder:  Xiph.Org libVorbis I 20030909
bitrate:  118
```

## corr - Pearson Product Moment Correlation Coefficient

Reads 2 columns, skipping non-numerics and outputs the
Pearson Product Moment Correlation Coefficient

Examples
--------
```
$ cat data  # mixture of text/data and differing whitespace
Col1  Col2
----  ----
1 3

non-data

3     9
5  8

$ corr /tmp/data
N = 3, r = 0.777713771047819
```

## cdataEncode - XML CDATA Encoder

Encode the input XML as CDATA, handling nested CDATA statements

Examples
--------
```
$ echo 'hello world' | cdataEncode 
<![CDATA[hello world
]]>

$ echo 'hello world' | cdataEncode | cdataEncode 
<![CDATA[<![CDATA[hello world
]]]]><![CDATA[>
]]>
```

## cutcol -- Generalized Column Cutter

Cut columns in various ways

```
cutcol.pl -statfile file.stats -field range -col RE [-delim str] [-outdelim str] [-(no)re] [-(no)label] [-preserve] [-quiet]
 -statfile file.stats   stats file
	-field range           column # or range
	-col STR               string matching column label in the stats file
	-re                    treat -col STR as regular expression (default)
	-label                 output the column label
	-delim delim           delimiter to split fields on (defaults to tab)
	-outdelim delim        output delimiter (defaults to delim) [use '\t' for tab]
	-preserve              output selected columns in original statfile order
	-quiet                 die silently on error
Examples:

	Given the following tab separated input in file 'test.stats':

		grade Predicted id
		2     3         1
		1     2         2
		1     1         3

	# output columns 'grade' and 'Predicted'
	cutcol.pl -col grade -col Predicted test.stats
	cutcol.pl -field 1 -field 2 test.stats

	# output columns 'grade' and 'Predicted'
	cutcol.pl -col gr -col Pre test.stats
	cutcol.pl -f 1-2 test.stats

	# output columns 'Predicted' and 'grade'
	cutcol.pl -col 'ed$' -col 'de$' test.stats
	cutcol.pl -f 2 -f 1 test.stats

	# output columns 'Predicted' and 'id'
	cutcol.pl -col '(?i)pre' -col 'id' test.stats

	# output all columns comma separated
	cutcol.pl -col . -outdelim=, test.stats

	# output columns 'id' and 'grade'
	cutcol.pl -col id -col grade test.stats

	# output columns 'grade' and 'id'
	cutcol.pl -preserve -col id -col grade test.stats

	# output all columns comma separated, then convert back to tab
	cutcol.pl -col=. -outdelim=, -statfile=test.stats | cutcol.pl -delim=, -col=. -outdelim='\t' -
 ```

## squeezeCommand -- Command Line Squeezebox Controller

Basic command line control of a Slimserver Squeezebox (play, pause, power, info, list, etc.)

Examples
--------
```
squeezeboxCommand.pl [-player|-id] cmd [args]
  cmd:
    players                -- show information on known players
    info                   -- show summary of the music library and players
    add file|dir [...]     -- add content to the current playlist
    pl(ay) file|dir [...]  -- clear current playlist, then add content
    pa(use)                -- pause toggle
    po(wer) [on|off]       -- power query and control
    list                   -- show song/album/artist in the current playlist
    n(ext) [-#|+#]         -- jump +/- in playlist, default is +1
    v(olume) [-#|+#|#]     -- volume query, +/- adjust, or set
    mi                     -- run external "mi" utility on the current music file
    
$ squeezeboxCommand.pl -list # current track is displayed in reverse video (not shown below)
+----------------------------+-------+----------+-------------------+
| Track                      | Time  | Album    | Artist            |
+----------------------------+-------+----------+-------------------+
| Restless                   |  3:35 | Restless | Eric Jerardi Band |
| Easy To Love, Easy To Hate |  4:47 | Restless | Eric Jerardi Band |
| Let It Ride                |  3:46 | Restless | Eric Jerardi Band |
| Self Defense               |  5:09 | Restless | Eric Jerardi Band |
| My Dog                     |  3:18 | Restless | Eric Jerardi Band |
| Jail                       |  2:52 | Restless | Eric Jerardi Band |
| Going Through The Motions  |  2:37 | Restless | Eric Jerardi Band |
| Kaboom                     |  2:34 | Restless | Eric Jerardi Band |
| L.A. Prelude               |  1:28 | Restless | Eric Jerardi Band |
| L.A.                       |  5:38 | Restless | Eric Jerardi Band |
| Get Back                   |  4:16 | Restless | Eric Jerardi Band |
| Such A Crime               |  3:35 | Restless | Eric Jerardi Band |
| Dent                       |  1:54 | Restless | Eric Jerardi Band |
| Wish I Could               |  3:41 | Restless | Eric Jerardi Band |
+----------------------------+-------+----------+-------------------+

$ squeezeboxCommand.pl -info
Slimserver Version: 7.5.5

Players:
player index: 0
player id:    00:01:02:03:04:05
player ip:    192.168.36.14:61859
player name:  Basement
player model: squeezebox2

player index: 1
player id:    ab:cd:ef:01:02:03
player ip:    192.168.36.15:46309
player name:  Living Room
player model: squeezebox

Library:
Artists: 2692
Albums:  8426
Songs:   103253

Basement power is: on
Basement current volume: 50

$ squeezeboxCommand.pl -vol=+5
Basement new volume: 55

$ squeezeboxCommand.pl -vol 42
Basement new volume: 42

$ squeezeboxCommand.pl -mi
Basement: /music/e/Eric\ Jerardi\ Band/Restless/08.\ Kaboom.mp3
title:    Kaboom
artist:   Eric Jerardi Band
album:    Restless
genre:    Blues
year:     2007
track:    08/14
time:     2:34
vbr:      yes
encoder:  LAME3.99r
version:  ID3v2.3.0
bitrate:  261
```

## sound.help -- self displaying sed script of sound utility notes

```
# various notes gathered over the years related to audio/video files
#

---------------------------------------------------------------------

To read the complete media from a CD-ROM writing the  data
to the file cdimage.raw:

readcd dev=0,0,0 f=cdimage.raw

---------------------------------------------------------------------

With CD-Record:
---------------
CD-Writing HowTo:
http://howto.linuxberg.com/ptHOWTO/CD-Writing-HOWTO

For example:
cdrecord -v speed=4 dev=1,0,0 mandrake.iso
You get the number on the SCSI bus number with "cdrecord --scanbus"

On Mac:
cdrecord -v dev=IODVDServices/0 -dao *.wav

---------------------------------------------------------------------

With nautilus-cd-burner:
/usr/bin/nautilus-cd-burner --source-iso=/home/farnham/Download/ubuntu-7.04-desktop-i386.iso

---------------------------------------------------------------------

Creating an iso image:

mkisofs -o /tmp/proj.iso -R proj

---------------------------------------------------------------------

To create an iso image from a CD (no need to mount)
cat /dev/cdrom > image.iso

---------------------------------------------------------------------

Blanking a CD-RW:

cdrecord dev=1,0,0 speed=4 blank=all
cdrecord dev=1,0,0 speed=4 blank=fast

  all         Blank  the entire disk. This may take a
              long time.

  fast        Minimally blank the disk. This  results
              in  erasing  the  PMA,  the TOC and the
              pregap.

---------------------------------------------------------------------

Ripping to WAV storing each track in a separate file:
cdparanoia -B
cdparanoia -d /dev/dvd1 -B

Recording the WAV's:
cdrecord -v speed=4 dev=1,0,0 -audio *.wav

Checking to see if double speed would work:
cdrecord -v -dummy speed=2 dev=1,0,0 -audio *.wav

To copy an audio CD:
cdda2wav -x -D1,0,0 -B
cdrecord -v dev=1,0,0 -dao *.wav
cdrecord -v dev=/dev/scd1 -pad -dao *.wav

To copy an audio CD with CDDB lookup for track names:
cdda2wav --dev=1,0,0 --max --alltracks --cddb=1

To rename audio*.wav to track names:
~/bin/renameTracks.pl audio.cddb

To record the WAV's to a blank CDR:
cdrecord -v speed=4 dev=1,0,0 *.wav

---------------------------------------------------------------------

Wax -> Digital

aumix                           # set recording levels
rec -w -c 2 -r 44100 file.wav   # SOX rec
gramofile                       # find and split tracks

---------------------------------------------------------------------

Downsampling:
    # create intermediate CAF file
    # input.wav: RIFF (little-endian) data, WAVE audio, Microsoft PCM, 24 bit, stereo 96000 Hz
    afconvert -d 0 -f caff input.wav intermediate.caf

    afconvert -d LEI16@44100 intermediate.caf outut.wav
    # output.wav: RIFF (little-endian) data, WAVE audio, Microsoft PCM, 16 bit, stereo 44100 Hz

         or

    afconvert -d LEI16@44100 -f WAVE input.wav output.wav

         or

    /usr/local/sox-14.3.0/bin/sox input.wav -b 16 -r 44100 output.wav
---------------------------------------------------------------------

Converting flac to alac:
    flac -d file.flac
    afconvert -d alac file.wav file.m4a

---------------------------------------------------------------------

Converting m4a to WAV:

   faad -o file.wav file.m4a
            or
   mplayer -vc dummy -vo null -ao pcm:file=music.wav music.m4a
            or
   afconvert -d LEI16 -f WAVE file.m4a file.wav
            or
   ffmpeg -i file.m4a file.wav

---------------------------------------------------------------------
Copying m4a to strip tags

ffmpeg -loglevel 0 -i input.m4a -vn -c:a copy output.m4a
ffmpeg -loglevel 0 -i input.m4a -vn -acodec copy output.m4a
            or
MP4Box -add infile.m4a#audio output.m4a

---------------------------------------------------------------------

Converting mp3 to WAV:

   madplay -o file.wav file.mp3
            or
   sox file.mp3 file.wav
            or
   mplayer -vc dummy -vo null -ao pcm:file=music.wav music.mp3
            or
   notlame --decode file.mp3 file.wav
            or
   afconvert -d LEI16 -f WAVE file.mp3 file.wav

---------------------------------------------------------------------

Converting WAV to m4a:

faac -q 120 -c 20000 -w file.wav       # encodes to file.m4a

#faac -q 130 -c 22000 -m 4 (~218 kbps)
#faac -q 120 -c 20000 -m 4 (~194 kbps)
#faac -q 110 -c 18000 -m 4 (~158 kbps)
#faac -q 100 -c 16000 -m 4 (~129 kbps)
#faac -q 90 -c 14000 -m 4 (~103 kbps)
#faac -q 80 -c 12000 -m 4 (~79 kbps)
#faac -q 70 -c 10000 -m 4 (~62 kbps)

On a Mac (intermediate caf file):
afconvert file.wav intermediate.caf -d 0 -f caff --soundcheck-generate
afconvert intermediate.caf -d aac -f m4af -u pgcm 2 --soundcheck-read -b 256000 -q 127 -s 2 file.m4a

---------------------------------------------------------------------

Converting WAV to mp3:

notlame -h -V 0 -b 112 file.wav file.mp3
           or
xingmp3enc -B 192 file.wav

---------------------------------------------------------------------

Converting WAV to ogg: --quality=6 is ~190 kbps

oggenc --artist='Dire Straits' \
       --album='Alchemy: Dire Straits Live' \
       --title='Sultans Of Swing' \
       --track=6 \
       --genre=Rock \
       --date=1984 \
       --quality=6 \
       06.\ Sultans\ Of\ Swing.wav

Listing the ogg tags:
  % vorbiscomment -l 06.\ Sultans\ Of\ Swing.ogg

Tagging an ogg file using a text file:
  % cat tags
    title=Sultans Of Swing
    artist=Dire Straits
    genre=Rock
    date=1984
    album=Alchemy: Dire Straits Live
    tracknumber=6

  % vorbiscomment -w -c tags file.ogg

Playing an ogg file:
  % mplayer file.ogg
         or
  % ogg123 file.ogg
         or
  % xmms file.ogg

---------------------------------------------------------------------

Converting ogg to WAV:
oggdec -o file.wav file.ogg
for f in *.ogg; do oggdec -o "${f%.ogg}.wav" "$f"; done

---------------------------------------------------------------------

Converting WMA to WAV:

mplayer -vc dummy -vo null -ao pcm:file=music.wav music.wma
         or
ffmpeg -i file.wma -f wav file.wav

---------------------------------------------------------------------

Concatinating 2 WAV's:

sox file1.wav -r 44100 -c 2 -s -w file1.raw
sox file2.wav -r 44100 -c 2 -s -w file2.raw
cat file1.raw file2.raw > file.raw
sox -r 44100 -c 2 -s -w file.raw file.wav

---------------------------------------------------------------------

Playing a DVD from a directory

mplayer dvd:// -dvd-device /path/to/dir

---------------------------------------------------------------------

Pulling the MP2 audio track off a DVD:

mplayer dvd:// -dvd-device /path/to/dir -dumpaudio -dumpfile stream.mp2
Convert the compressed audio (48000Hz MP2) to a 44100Hz 2ch Signed 16-bit WAV
mplayer stream.mp2 -af resample=44100 -ao pcm:file=stream.wav

      or from the DVD device (dvd://1)

mplayer -vo null -vc dummy -ao pcm:file=music.wav dvd://1
mplayer -vo null -vc dummy -ao pcm:file=stream.wav /export/data/public/Music/WP_EARTH_TO_ATLANTA_2.ISO
mplayer -vo null -vc null -ao pcm:file=stream.wav dvd:// /media/dvdrecorder

      followed by (dvd://2)

mplayer -vc null -vo null -ao pcm:file=music.wav dvd://2 -dvd-device ./Gary_Moore

Pull the mp2 track off and resample
mplayer -vo null -vc dummy -af resample=44100 -ao pcm:file=stream.wav LIVE_BABY_LIVE.ISO

Pull the audio track with id 130 (-aid 130, use -v to find id's), resample.
mplayer -vo null -vc dummy -aid 130 -af resample=44100 -ao pcm:fast:file=stream130.wav LIVE_BABY_LIVE.ISO

Pull the audio track with id 160 resample.
mplayer -vo null -vc dummy -aid 160 -af resample=44100 -ao pcm:fast:waveheader:file=music.wav dvd://2

Split into individual tracks.
foreach f ( `series 1 16` )
foreach? mplayer -vo null -vc dummy -aid 160 -af resample=44100 -ao pcm:fast:file=$f.wav -chapter $f-$f dvd://2
foreach? end


Pull the audio track with id 129, resample -- dvd is mounted as "/dev/cdrom1" which is device "/dev/dvd1"
mplayer -vo null -vc dummy -aid 129 -af resample=44100 -ao pcm:fast:waveheader:file=stream.wav dvd:// -dvd-device /dev/dvd1

---------------------------------------------------------------------

Increase volume of a wav file to a target amplitude of -12dBFS

normalize -a -12dBFS file.wav

---------------------------------------------------------------------

Backup a directory to a dvd

growisofs -J -R -Z /dev/dvdwriter -speed=2 /path/to/dir

---------------------------------------------------------------------

Erasing a dvd-rw

dvd+rw-format -force /dev/dvd

---------------------------------------------------------------------
To copy a DVD using DVD Shrink

wine .wine/drive_c/Program\ Files/DVD\ Shrink/DVD\ Shrink\ 3.2.exe

Write from the ripped directory to dvd
growisofs -dvd-compat -Z /dev/dvdwriter -dvd-video -V LABEL /path/to/dvd/image/

Write from the iso to dvd
growisofs -dvd-compat -Z /dev/dvdrw=/export/data/public/Music/BORAT_16X9.ISO

---------------------------------------------------------------------
To burn a DVD iso on a Mac

hdiutil burn DESPICABLE_ME.ISO

---------------------------------------------------------------------
To convert wma to wav

foreach f ( *.wma )
foreach? mplayer -vo null -quiet -srate 44100 -channels 2 -vc dummy -ao pcm:waveheader:fast:file="$f.wav" "$f"
foreach? end

---------------------------------------------------------------------
To split a flac file with associated cue file into wav tracks

# Disc5.flac is entire disc with Disc5.cue describing the tracks.
# Output files named (track01,track02...) via "-a track"
cuebreakpoints Disc5.cue | shnsplit -a track -o wav Disc5.flac

---------------------------------------------------------------------
To set flac tags

metaflac --set-tag=Artist='B.B. King' --set-tag=Album='Live At The Royal Albert Hall 2011' --set-tag=Genre=Blues --set-tag=Date=2011 *.flac
tagit.flac
tracks.flac
metaflac --set-tag='Encoded-by=flac --best' *.flac

---------------------------------------------------------------------
Using ape (Monkey Audio File)

Examples:
    Compress: mac file.wav output.ape -c2000
    Decompress: mac file.ape file.wav -d

ffmpeg -i file.ape output.wav

java -jar jmac.jar d file.ape output.wav
java -jar jmac-1.74/distributables/jmac.jar c1 CaffeinatedRattlesnake.wav CaffeinatedRattlesnake.ape

---------------------------------------------------------------------
Mounting an ISO on a Mac

hdiutil attach -imagekey diskimage-class=CRawDiskImage -mount file.iso
  # command responds with device "/dev/disk2"
hdiutil mount /dev/disk2

---------------------------------------------------------------------

Burning .iso on Mac

DON'T burn the .iso directly
DO convert it to a .cdr first, then burn it!  Here's how:

1. Open Disk Utility
2. Drag & drop the .iso onto the left panel (under where you see your HD listed), or in some other manner get it into the left panel (may vary with the version of OSX you are using)
3. Highlight the .iso
4. Choose "Convert" at the top
5. IMPORTANT: Choose "DVD/CD master" for the image format
6. For encryption choose "none"
7. Click "Save", and make sure the file type is ".cdr" (you can keep the .iso if you want as well)
8. After some time, you will have another image; burn that image
9. Insert a writable CD or DVD, and choose the slowest possible burn time (for safety)
10. Choose to verify the disk you are burning as well, then click "Burn"
11. Depending on what OS built the .iso, the result may not be readable by your Mac, but  the PC or hypervisor where you will install it will be able to read and boot it

---------------------------------------------------------------------

MP3 Compilation tag
eyeD3 --text-frame=TCMP:1

---------------------------------------------------------------------

flac to alac
for f in *.flac; do ffmpeg -loglevel 0 -i "$f" -acodec alac "${f%.flac}.m4a"; done

---------------------------------------------------------------------

remove all m4a tags
for f in *.m4a; do MP4Box -itags all=NULL "$f"; done
```

## utf8norm -- UTF8 Normalization

```
Usage: utf8norm [-help] [-para] [-squeeze] [-output file] file|stdin

Available options:
  -h, --help            Help
  -o, --output=<file>   Output File
  -p, --paragraph       Read in Perl style paragraph mode
  -s, --squeeze         Squeeze Whitespace
```

## hexbytes -- I/O in hex

```
hexbytes [-nmrs] file|stdin
  -n  output a trailing newline
  -m  i/o in ModHex (mapping: cbdefghijklnrtuv => 0123456789abcdef)
  -r  input is hex, output decoded characters
  -s  strip trailing byte on input data
```

## mp3enc -- Front end to lame handling wav, aiff, m4a, ogg, flac

## itunesPlus -- afconvert wav, aiff, flac with appropriate flags
