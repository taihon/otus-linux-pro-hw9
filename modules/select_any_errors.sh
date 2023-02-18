#!/bin/bash

function select_any_errors(){
    awk 'BEGIN {FS="\" " ; OFS="©"} ; {print $0,$2}' | awk 'BEGIN { FS = "©" }; { if (!(match($2,/(2.*|301)/))) { print $1 }}'
}