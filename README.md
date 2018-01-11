# IGV-autoload
Script to enhance the process of visualisation in IGV

This function makes it easier to use the Intergrative Genomics Viewer.\n
It will ask to enter a reference genome and an alignment file.
These files will be converted and sorted. It will start IGV with
the reference genome and the alignment specified by the user.
All generated files will be removed when the user exits IGV.
IGV and samtools are required to run this function. The function
will install these packages if they're not installed yet.
This function only accepts fasta and fastQ files as reference genomes
and sam or bam files as alignment files. These files can be specified
as parameters. The user will be asked for the files by the program if
these parameters are missing. This script only works with absolute paths!
The working directory moves automaticly to ~/ so don't add ~/ to the path.
The program won't work if there are spaces in one of the directory names.
If IGV or samtools are not installed yet, an internet connection is required.
Usage:
  ./functie.sh -a fileA.sam -a fileB.bam -f refgen.fasta
  ./functie.sh -a fileA.sam -a fileB.bam -g hg18
  ./functie.sh -a fileA.sam -a fileB.bam -b
  ./functie.sh -h
  ./functie.sh
Options:
  -h
	  Show usage information
  -f
	  Enter the path to the reference genome after this option. This option
	  may not be empty and it has to be used in combination with -a.
	  It's not possible to use -f and -g at the same time.
  -g 
	  Use a reference genome from IGV. The codes can be found on this website:
	  http://software.broadinstitute.org/software/igv/Genomes. It is not
	  possible to use -g and -f at the same time. This option may not be empty
	  and has to be used in combination with -a. Internet connection is required
	  for this option.
  -a 
	  Add a path to an alignment file after this option. This option can be
	  used multiple times. This option may not be empty and it has to be used
	  in combination with -f and -g.
  -b 
      Sort or convert and sort an alignment file to a BAM file. IGV won't be started
      and the sorted bam file won't be deleted.
Dependencies:
  -IGV 2.0
  -samtools-0.1.19
Authors: Jasper van Dalum, Jasper Ouwerkerk, Paul de Raadt,
Tjardo Maarsveen & Giovanni van Donge
Version 6.1					Dec 21 2017
