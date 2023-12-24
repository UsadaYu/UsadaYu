#!/bin/bash

set -e

aarch64-linux-gnu-hi3519dv500-v2-gcc -g -O0 -o 003_helloWorld 003_helloWorld.s 

sudo xcp 003_helloWorld /share/$USER/
