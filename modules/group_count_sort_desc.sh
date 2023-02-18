#!/bin/bash
function group_count_sort_desc(){
    sort | uniq -c | sort -rn
}