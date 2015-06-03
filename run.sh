#!/bin/sh

argos3 -c decision-making.xml | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//gw info.txt"
cat info.txt output.txt > result.txt
rm info.txt output.txt
