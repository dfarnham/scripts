#!/usr/bin/env python3

import sys
import numpy as np

if len(sys.argv) < 2:
    print(f"Usage: {sys.argv[0]} cols [file|stdin]")
    exit(1)

cols = int(sys.argv[1])


def read_data(fh):
    """Return a list of lines read from an open file handle. Skip blank lines."""
    return [ line.strip() for line in fh if len(line.strip()) > 0 ]

# read input data
if len(sys.argv) == 2:
    data = read_data(sys.stdin)
else:
    with open(sys.argv[2], "r") as fp:
        data = read_data(fp)


# find the longest string in each column for use in padded output
# one possible straight forward and simple algorithm:
#   pad = [0] * cols
#   for i in range(len(data)):
#       n = i % cols
#       if len(data[i]) > pad[n]:
#           pad[n] = len(data[i])
#
# could also run a max function over the length of the strings in each column.
# one solution is to reshape after adding the appropriate number of [0] elements.

# gather up the string lengths and add enough [0]'s to satisfy numpy.reshape()
lengths = [len(str) for str in data] +   [0] * (cols - len(data) % cols)

# run a max function over each column after reshape()
# creating a list containing the max string length for each column
pad = [max(np.array(lengths).reshape(len(lengths)//cols, cols)[:,i]) for i in range(cols)]

# output original data [blank lines removed: see read_data()] with column padding
for i in range(len(data)):
    n = i % cols
    print(data[i], ' ' * (pad[n] - lengths[i] + 1), end = '' if n != cols-1 else '\n')

# finally, output a newline for short data
if (len(data) % cols):
    print("")
