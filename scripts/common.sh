#!/bin/bash

# set env
RAINBOND_HOMEPAGE="https://www.rainbond.com"


# function
function log_info(){
  echo -ne "\t$1 "
}

function log_succeed(){
  echo -e "\033[32m OK! \033[0m"
}

function log_error(){
  echo -e "\033[31m ERROR! \033[0m"
}

