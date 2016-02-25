#!/usr/bin/env bash

# Named variables. Every run needs the following defined:
# 1) -o | --output_dir - The directory where the Trinity files should be written. Each new assembly will be placed in it's own directory in the format Genus_SPECIES_trinity
# 2) -bu | --backup_dir - The directory to copy the final Trinity.fa assembly files.
# 3) -t | --threads - The number of threads Trinity will use. You will need 10G of RAM per thread for Butterfly.
# 4) -e | --trinity_directory - The directory where your trinity executable is located.
# Example: assemble_go_trinity.sh -o /home/assemblies/haptophytes -t 7 -e /home/mendezg/bin/trinityrnaseq_r20140717/Trinity -bu /home/mendezg/backup_assemblies

# version 7/17/2014 Trinity location
# /home/mendezg/bin/trinityrnaseq_r20140717/Trinity

#Code to handle the named variable inputs:
while [[ $# > 1 ]]
do
key="$1"

case $key in
  -o|--output_dir)
  OUT_DIR="$2"
  shift # past argument
  ;;
  -bu|--backup_dir)
  BACKUP_DIR="$2"
  shift # past argument
  ;;
  -t|--threads)
  THREADS="$2"
  shift # past argument
  ;;
  -e|--trinity_directory)
  TRINITY_DIR="$2"
  shift # past argument
  ;;
  *)
        # unknown option
  ;;
esac
shift # past argument or value
done

#LOGGING
echo New assemble_go_trinity.sh run started on $(date) >> $OUT_DIR/log.txt
echo Trinity location = "$TRINITY_DIR" >> $OUT_DIR/log.txt
echo Output Directory = "$OUT_DIR" >> $OUT_DIR/log.txt
echo Backup Directory = "$BACKUP_DIR" >> $OUT_DIR/log.txt
echo Threads = "$THREADS" >> $OUT_DIR/log.txt
RAM_MULTIPLIER=10
RAM=$(($RAM_MULTIPLIER * $THREADS))
echo Java Memory = "$RAM" >> $OUT_DIR/log.txt

#Loop through directories and assemble using previously create all.1.clean.fastq.gz and all.2.clean.fastq.gz files generated by the initial trimming script.
for i in *
do 
  DIR=$PWD
  echo INPUT DIRECTORY = $DIR >> $OUT_DIR/log.txt
  if [ -d $i ]
  then
    cd $i
    SPECIES=${PWD##*/}
    if [ ! -d $OUT_DIR/$SPECIES\_trinity ]
    then
       echo "********************************************************************************"
       echo "                            $SPECIES "
       echo "********************************************************************************"
       echo $SPECIES starting on $(date) >> $OUT_DIR/log.txt
      $TRINITY_DIR/Trinity --seqType fq --left $PWD/all.1.clean.fastq.gz --right $PWD/all.2.clean.fastq.gz --JM $RAM'G' --CPU $THREADS --output $OUT_DIR/$SPECIES\_trinity
       echo $SPECIES completed on $(date) >> $OUT_DIR/log.txt
      cp $OUT_DIR/$SPECIES\_trinity/Trinity.fasta $BACKUP_DIR/$SPECIES.fa
    fi
  cd $DIR
  fi
done

# Run cleanup script
cd $OUT_DIR
delete_assembly.sh