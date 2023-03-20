#!/bin/bash

timeout 10 nc -z 192.168.86.10 22 2> /dev/null
[[ $? != 0 ]] && sudo wg-quick up wg0
