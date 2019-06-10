#!/bin/bash
#COBALT -A CSC250STTO11
#COBALT -t 00:30:00
#COBALT -n 8
#COBALT -q debug-cache-quad

aprun -n 512 -N 64 -cc depth -d 1 -j 1 hpcrun -o hpctoolkit-amg2013-8x8x8-measurements -e WALLCLOCK@2000 -t ./amg2013 -pooldist 0 -r 12 12 12 -P 8 8 8

aprun -n 512 -N 64 -cc depth -d 1 -j 1 hpcprof-mpi -S amg2013.hpcstruct hpctoolkit-amg2013-8x8x8-measurements

