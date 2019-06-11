#!/bin/bash
#COBALT -A CSC250STTO11
#COBALT -t 01:00:00
#COBALT -n 8
#COBALT -q debug-cache-quad

for i in {1..3}
do
aprun -n 512 -N 64 -cc depth -d 1 -j 1 hpcrun -e WALLCLOCK@5000 -t -o hpctoolkit-laghos-p1-512-$i-measurements ./laghos -p 1 -m data/cube01_hex.mesh -rs 3 -rp 2 -tf 0.6 -no-vis -pa -pt 111 --max-steps 20
aprun -n 512 -N 64 -cc depth -d 1 -j 1 hpcprof-mpi -S laghos.hpcstruct --metric-db no hpctoolkit-laghos-p1-512-$i-measurements
done

<<COMMENT1
echo "1"
aprun -n 64 -N 64 -cc depth -d 1 -d 1  ./laghos -p 0 -m data/square01_quad.mesh -rs 3 -tf 0.75 -no-vis -pa

echo "2"
aprun -n 64 -N 64 -cc depth -d 1 -d 1  ./laghos -p 0 -m data/cube01_hex.mesh -rs 1 -tf 0.75 -no-vis -pa

echo "3"
aprun -n 64 -N 64 -cc depth -d 1 -d 1  ./laghos -p 1 -m data/square01_quad.mesh -rs 3 -tf 0.64 -no-vis -pa

echo "4"
aprun -n 64 -N 64 -cc depth -d 1 -d 1  ./laghos -p 1 -m data/cube01_hex.mesh -rs 2 -tf 0.6 -no-vis -pa

echo "5"
aprun -n 64 -N 64 -cc depth -d 1 -d 1  ./laghos -p 2 -m data/segment01.mesh -rs 5 -tf 0.2 -no-vis -fa

echo "6"
aprun -n 64 -N 64 -cc depth -d 1 -d 1  ./laghos -p 3 -m data/rectangle01_quad.mesh -rs 2 -tf 3.0 -no-vis -pa

echo "7"
aprun -n 64 -N 64 -cc depth -d 1 -d 1  ./laghos -p 3 -m data/box01_hex.mesh -rs 1 -tf 3.0 -no-vis -pa

COMMENT1

