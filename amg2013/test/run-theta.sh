#!/bin/bash
#COBALT -A CSC250STTO11
#COBALT -t 00:30:00
#COBALT -n 128
#COBALT -q default
#debug-cache-quad

for i in {1..3}
do
	aprun -n 1728 -N 64 -cc depth -d 1 -j 1 hpcrun -o hpctoolkit-amg2013-12x12x12-$i-measurements -e WALLCLOCK@2000 -t ./amg2013 -pooldist 0 -r 12 12 12 -P 12 12 12 &
	sleep 1
done

for i in {1..3}
do
	aprun -n 512 -N 64 -cc depth -d 1 -j 1 hpcrun -o hpctoolkit-amg2013-8x8x8-$i-measurements -e WALLCLOCK@2000 -t ./amg2013 -pooldist 0 -r 12 12 12 -P 8 8 8 &
	sleep 1
done

wait




for i in {1..3}
do
    aprun -n 1728 -N 64 -cc depth -d 1 -j 1 hpcprof-mpi -S amg2013.hpcstruct hpctoolkit-amg2013-12x12x12-$i-measurements &
	sleep 1
done

for i in {1..3}
do
    aprun -n 512 -N 64 -cc depth -d 1 -j 1 hpcprof-mpi -S amg2013.hpcstruct hpctoolkit-amg2013-8x8x8-$i-measurements &
	sleep 1
done

wait

