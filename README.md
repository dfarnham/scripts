
## Pairing

szudzik & cantor

```
pairing.pl [-cantor|-szudzik] stdin|file  # -szudzik is default

Given pairs of input: output the pairing function value (using cantor or szudzik)
Given single inputs: output the original pairs

Example:
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

## mi - Music Info
 
Utility to extract tag information from various music file formats or
display a pretty-printed album style summary from a directory or set of files

Examples
------------
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

$ mi /music/b/Buddaheads/Howlin\'\ At\ The\ Moon/01.\ Long\ Way\ Down.mp3 
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

$ mi /music/Loseless/Donna\ The\ Buffalo/Rockin\'\ In\ The\ Weary\ Land/01.\ Tides\ Of\ Time.flac 
title:    Tides Of Time
artist:   Donna The Buffalo
album:    Rockin' In The Weary Land
genre:    Alternative Country
year:     1998
track:    01/12
time:     3:27
encoder:  flac --best
bitrate:  16 bits per sample @ 44100Hz

$ mi /music/p/Paul\ Reddick\ \&\ The\ Sidemen/Rattlebag/13.\ Smokehouse.ogg 
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
------------
```
$ cat /tmp/data  # mixture of text/data and differing whitespace
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
------------
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
------------
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
