#!/bin/bash 

cd "$(dirname "$0")"

for s in `ls scripts/*.sh`; do
   echo Going to start $s
   $s & 
done 
