#!/bin/bash

function read_n_lines(){
    if [ $1 != "all" ];
    then
        head -n $1;
    else
        cat
    fi
}