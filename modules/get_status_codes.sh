#!/bin/bash
function get_status_codes(){
    awk 'BEGIN { FS = "\""} {print $3}'|awk '{print $1}'
}