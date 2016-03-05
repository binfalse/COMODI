#!/bin/bash

cat whole.svg | sed 's%^<svg%<svg\n   xmlns:xlink="http://www.w3.org/1999/xlink"%' | sed 's%>\([a-zA-Z]\+\)</text>%><a xlink:href="http://purl.uni-rostock.de/comodi/comodi#\1">\1</a></text>%' > whole-incl-links.svg
