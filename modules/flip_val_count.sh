#!/bin/bash
function flip_val_count(){
    awk '{print $2" "$1}'
}