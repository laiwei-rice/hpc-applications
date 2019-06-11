#!/bin/bash
#COBALT -A CSC250STTO11
#COBALT -t 01:00:00
#COBALT -n 8
#COBALT -q debug-cache-quad

for i in {1..2}
do
aprun -n 512 -N 64 -cc depth -d 1 -j 1 hpcrun -e WALLCLOCK@5000 -t -o hpctoolkit-pflotran-512-$i-measurements /home/laiwei/install/pflotran-gnu7.3.0/bin/pflotran
aprun -n 512 -N 64 -cc depth -d 1 -j 1 hpcprof-mpi -S pflotran.hpcstruct --metric-db no hpctoolkit-pflotran-512-$i-measurements


aprun -n 512 -N 64 -cc depth -d 1 -j 1 hpcrun -e WALLCLOCK@5000 -t -o hpctoolkit-opt-pflotran-512-$i-measurements /home/laiwei/install/opt-pflotran-gnu7.3.0/bin/pflotran
aprun -n 512 -N 64 -cc depth -d 1 -j 1 hpcprof-mpi -S opt-pflotran.hpcstruct --metric-db no hpctoolkit-opt-pflotran-512-$i-measurements
done


