#!/bin/bash

mkdir -p out

for i in {1..30}
do
    echo "$i/30"
    argos3 -c decision-making.xml | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//gw info.txt"
    cat info.txt output.txt > out/result$i.txt
    rm info.txt output.txt
done
    
