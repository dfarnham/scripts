<a name="mi"/>
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

