#!/usr/bin/env python3

#import numpy as np
import sys
import math
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("-c", "--cols", type=int, help="number of columns")
parser.add_argument("-r", "--rows", type=int, help="number of rows")
parser.add_argument("-p", "--pad",  type=int, help="number of additional spaces between row elements")
parser.add_argument("-s", "--square", action="store_true", help="square output")
parser.add_argument("file", nargs='?', type=argparse.FileType("r"), default=sys.stdin, help="file|stdin")
args = parser.parse_args()


def read_data(fh):
    """Return a list of lines read from an open file handle. Omitting blank lines."""
    return [ line.strip() for line in fh if len(line.strip()) > 0 ]


if args.cols and args.rows: parser.parse_args(['--help'])
if args.square and (args.cols or args.rows): parser.parse_args(['--help'])

# read input data
#if args.file == None or args.file == '-':
#    data = read_data(sys.stdin)
#else:
#    with open(args.file, "r") as fp:
#        data = read_data(fp)
data = read_data(args.file)

# all calculations are based on the number of columns needed
if args.cols:
    cols = args.cols
elif args.rows:
    cols = math.ceil(len(data) / args.rows)
else:
    cols = int(math.sqrt(len(data)))

# find the longest string in each column for use in padded output
# one possible straight forward and simple algorithm:
#   pad = [0] * cols
#   for i in range(len(data)):
#       n = i % cols
#       if len(data[i]) > pad[n]:
#           pad[n] = len(data[i])
#
# could also run a max function over the length of the strings in each column.
# one solution is to reshape() after adding the appropriate number of [0] elements.

# gather up the string lengths and add enough [0]'s to satisfy numpy.reshape()
lengths = [len(str) for str in data] +   [0] * (cols - len(data) % cols)

# run a max function over each column after reshape() creating
# a list containing the max string length for each column
#
# equivalently, the zip() pairings can act as the transpose avoiding the use of numpy.reshape()
#pad = [max(np.array(lengths).reshape(len(lengths)//cols, cols)[:,i]) for i in range(cols)]
pad = [max(lst) for lst in zip(*[lengths[i:cols+i] for i in range(0, len(lengths), cols)])]

additional_pad = args.pad if args.pad else 0

# output original data [blank lines removed: see read_data()] with column padding
for i in range(len(data)):
    n = i % cols
    print(data[i], ' ' * (pad[n] - lengths[i] + additional_pad), end = '' if n != cols-1 else '\n')

# finally, output a newline for short data
if (len(data) % cols): print("")
