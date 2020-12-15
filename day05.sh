#!/usr/bin/env bash

FILE=$1
shift

# input processing
declare -A nums
while read n
do
  # substitute
  ns=$(tr FBLR 0101 <<< "$n")
  # bash hack -- convert binary to decimal
  b=$((2#${ns}))
  # insert into associative array where key=value
  nums["$b"]="$b"
done < ${FILE}

# part 1 -- determine max, but also update min
min=max=$b
for i in "${!nums[@]}"
do
  (( i > max )) && max=$i
  (( i < min )) && min=$i
done
echo $max

# part 2 -- walk through [min, max] and find missing
for ((i=min; i<=max; i++))
do
  if ! [[ -n "${nums[$i]}" ]]
  then
      echo $i
      exit
  fi
done
