#!/bin/bash
function select_urls(){
    awk 'BEGIN { FS = "\""};{print $2}'| awk '{print $2}'
}