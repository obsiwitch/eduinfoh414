#!/bin/bash

mkdir -p out

for i in {1..10}
do
    echo "$i/10"
    argos3 -c decision-making.xml | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//gw conf$i.txt"
    mv conf$i.txt out/
    mv output.txt out/result$i.txt
done
    
