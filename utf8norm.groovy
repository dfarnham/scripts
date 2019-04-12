#!/usr/bin/env groovy

import java.text.Normalizer

/*
 *                     Canonical normalization
 *
 * Canonical normalization comes in 2 forms: NFD and NFC. The two are
 * equivalent in the sense that one can convert between these two forms
 * without loss. Comparing two strings under NFC will always give the
 * same result as comparing them under NFD.
 *
 * NFD
 *
 *   NFD has the characters fully expanded out. This is the faster
 *   normalization form to calculate, but the results in more code points
 *   (i.e. uses more space) If you just want to compare two strings that
 *   are not already normalized, this is the preferred normalization form
 *   unless you know you need compatability normalization
 *
 * NFC
 *
 *   NFC recombines code points when possible after running the NFD
 *   algorithm. This takes a little longer, but results in shorter
 *   strings.
 *
 *
 *                     Compatibility Normalization
 *
 * Unicode also includes many characters that really do not belong, but
 * were used in legacy character sets. Unicode added these to allow
 * text in those character sets to be processed as Unicode, and then be
 * converted back without loss.
 *
 * Compatibility normalization converts these to the corresponding
 * sequence of "real" characters, and also performs canonical
 * normalization. The results of compatibility normalization may not
 * appear identical to the originals.
 *
 * NFKC/NFKD
 *
 *   Compatibility normalization form comes in two forms NFKD and NFKC.
 *   They have the same relationship as between NFD and NFC.
 *
 *   Any string in NFKC is inherently also in NFC, and the same for the
 *   NFKD and NFD. Thus NFKD(x)=NFD(NFKC(x)), and NFKC(x)=NFC(NFKD(x))
 */


/* *****************************************************************
 *                        main()
 * *****************************************************************/
// Unicode UTF-8 encoding
String charsetName = "UTF-8"

// Set STDOUT to UTF-8 encoding
try {
    System.setOut(new PrintStream(System.out, true, charsetName))
} catch (UnsupportedEncodingException uee) {
    System.err.println("Failure setting STDOUT to " + charsetName + " : " + uee.getMessage())
    System.exit(1)
}

def cli = new groovy.cli.picocli.CliBuilder(
    width: 100,
    usage: 'utf8norm [-help] [-para] [-squeeze] [-output file] file|stdin',
    header: '\nAvailable options:')
cli.h(longOpt:'help',      'Help')
cli.p(longOpt:'paragraph', 'Read in Perl style paragraph mode', args:0, required:false, argName:'para')
cli.o(longOpt:'output',    'Output File',                       args:1, required:false, argName:'file')
cli.s(longOpt:'squeeze',   'Squeeze Whitespace',                args:0, required:false, argName:'squeeze')
def opt = cli.parse(args)
if (!opt) System.exit(1)

if (opt.help) {
    cli.usage()
    System.exit(0)
}

def extraArguments = opt.arguments()

// Attach inputStream to a file or stdin
def inputStream = null
if (extraArguments.size() == 0 || (extraArguments.size() == 1 && extraArguments[0] == '-')) {
    inputStream = new InputStreamReader(System.in, charsetName)
} else {
    inputStream = new File(extraArguments[0]).newReader(charsetName)
}   

// Attach outputStream to a file or stdout
def outputStream = (opt.output) ? new File(opt.output).newWriter(charsetName) : System.out

if (opt.paragraph) {
    while (textmap = textRead(inputStream, true)) {
        outputStream.write(textmap.header + "\n")
        outputStream.write(normalizeText(textmap.text, opt.squeeze) + "\n")
        if (opt.squeeze) {
            outputStream.write("\n")
        }
    }
} else {
    outputStream.write(normalizeText(inputStream.getText(), opt.squeeze))
}

// Clean up
outputStream.close()
System.exit(0)



/* *****************************************************************
 * normalizeText
 *   UTF-8 normalization + additional compatibility replacements
 *   Optional whitespace collapsing (squeeze)
 * *****************************************************************/
String normalizeText(txt, squeeze) {
    /*
     * Replace with quotation mark: U+0022
     *   U+2033 double prime
     *   U+2036 reversed double prime
     *
     * Note: Do this substitution first as NFKC will turn these into
     *       a multi character replacement.  Instead, replace with
     *       a quotation mark before NFKC is run.
     *
     *       NFKC will do the following:
     *         [″]{U+2033} => [′′]{U+2032}{U+2032}
     *         [‶]{U+2036} => [‵‵]{U+2035}{U+2035}
     */
    txt = txt.replaceAll(/[\u2033\u2036]/,'\u0022')


    // UTF-8 normalization (NFD, NFC, NFKD, NFKC)
    txt = Normalizer.normalize(txt, Normalizer.Form.NFKC)


    /*
     * Replace with hyphen-minus: U+002D
     *   U+2010 hyphen
     *   U+2011 non-breaking hyphen
     *   U+2012 figure dash
     *   U+2013 en dash
     *   U+2014 em dash
     *   U+2015 horizontal bar
     */
    txt = txt.replaceAll(/[\u2010\u2011\u2012\u2013\u2014\u2015]/,"\u002D")

    /*
     * Replace with apostrophe: U+0027
     *   U+2018 left single quotation mark
     *   U+2019 right single quotation mark
     *   U+201B single high-reversed-9 quotation mark
     *   U+2032 prime
     *   U+2035 reversed prime
     */
    txt = txt.replaceAll(/[\u2018\u2019\u201B\u2032\u2035]/,"\u0027")

    /*
     * Replace with quotation mark: U+0022
     *   U+201C left double quotation mark
     *   U+201D right double quotation mark
     *   U+201F double high-reversed-9 quotation mark
     *   U+301D reversed double prime quotation mark 
     *   U+301E double prime quotation mark
     */
    txt = txt.replaceAll(/[\u201C\u201D\u201F\u301D\u301E]/,'\u0022')

    /*
     * Replace with comma: U+002C
     *   U+201A single low-9 quotation mark
     *   U+3001 small ideographic comma
     */
    txt = txt.replaceAll(/[\u201A\u3001]/,"\u002C")

    /*
     * collapse runs of separators & whitespace to a single space and
     * remove leading & trailing whitespace
     *
     * \p{Z}: any kind of whitespace or invisible separator.
     *   \p{Zs}: a whitespace character that is invisible, but does take up space.
     *   \p{Zl}: line separator character U+2028.
     *   \p{Zp}: paragraph separator character U+2029.
     * \p{Space}: A whitespace character: [ \t\n\x0B\f\r]
     */
    if (squeeze) {
        return txt.replaceAll(/[\p{Space}\p{Z}]+/, "\u0020").trim()
    } else {
        return txt
    }
}



/* *****************************************************************
 * Read in "paragraph mode", detect header if batchMode is set
 * *****************************************************************/
def textRead(reader, batchMode) {
    String header = ""
    String text = ""
    while (reader && (line = reader.readLine()) != null) {
        // match line like "[abc=xyz]..." as header
        if (batchMode && text == "" && header == "" && line =~ /^\[[^=\[\]]+=[^\[\]]+]/) {
            header = line
            continue
        }
        if (line =~ /^$/) {
            if (text != "") {
                return([header:header, text:text])
            }
        } else {
            text += line + "\n"
        }
    }

    return (header == "" && text == "") ? null : [header:header, text:text]
}
