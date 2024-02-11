#!/bin/bash

chunk_sizes=(4 8 16 32 64 128 256 512 2048 4096)
set -x;
set -e;

for chunk_size in "${chunk_sizes[@]}"; do
	echo Chunk size $chunk_size
	yes | mdadm --create --verbose /dev/md0 --level=0 --raid-devices=4 --chunk=$chunk_size /dev/nvme0n1 /dev/nvme1n1 /dev/nvme2n1 /dev/nvme3n1
	yes | mkfs.ext4 /dev/md0
	mount /dev/md0 /mnt/testers/d0
	chown -R avery:magicloop /mnt/testers
	find /mnt/large-storage/perf2 -type f -name "read*" | parallel -j 16 cp -p {} /mnt/testers/d0/{/}
	fio --numjobs 24 disktest.fio > results/md_0_4_${chunk_size}
done

for chunk_size in "${chunk_sizes[@]}"; do
	echo Chunk size $chunk_size
	yes | mdadm --create --verbose /dev/md0 --level=10 --raid-devices=4 --chunk=$chunk_size /dev/nvme0n1 /dev/nvme1n1 /dev/nvme2n1 /dev/nvme3n1
	sleep 10
	yes | mkfs.ext4 /dev/md0
	sleep 10
	mount /dev/md0 /mnt/testers/d0
	sleep 10
	chown -R avery:magicloop /mnt/testers
	sleep 10
	find /mnt/large-storage/perf2 -type f -name "read*" | parallel -j 16 cp -p {} /mnt/testers/d0/{/}
	sleep 10
	fio --numjobs 24 disktest.fio > results/md_10_4_${chunk_size}
	sleep 10
	umount /mnt/testers/d0
	sleep 10
	mdadm --stop /dev/md0
	sleep 10
done

