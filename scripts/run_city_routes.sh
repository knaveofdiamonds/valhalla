#!/bin/bash
files=$(ls -b city_to_city)

for f in ${files[@]}
do
  PATH=../:${PATH} ./batch.sh city_to_city/$f
done

exit
