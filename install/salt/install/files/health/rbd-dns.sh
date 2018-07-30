#!/bin/bash

isExist=`ss -lnu | grep :53 | wc -l`

if (($isExist == 1)); then
  exit 0
else
  exit 1
fi