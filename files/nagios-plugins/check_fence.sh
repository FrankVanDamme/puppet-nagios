#!/bin/bash

host=$1
fence_res_out="$(crm resource status p_fence_$host 2>&1)"
echo -n "FENCE_$host "

echo $fence_res_out | grep -q "^resource p_fence_${host} is running on: "
running=$?

if [[  $running -eq 0 ]]
then
    echo OK: running
else
    if [[ "$fence_res_out" == "resource p_fence_"${host}" is NOT running" ]]
    then
        echo CRITICAL: $fence_res_out
        exit 2
    fi  
    echo WARNING: $fence_res_out
    exit 1
fi

