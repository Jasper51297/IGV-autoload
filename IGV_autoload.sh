#!/bin/bash

function help {
	bold=$(tput bold)
	normal=$(tput sgr0)
	printf "${bold}IGV Autoload${normal}\n"
	printf "This function makes it easier to use the Intergrative Genomics Viewer.\n"
	printf "It will ask to enter a reference genome and an alignment file.\n"
	printf "These files will be converted and sorted. It will start IGV with\n"
	printf "the reference genome and the alignment specified by the user.\n"
	printf "All generated files will be removed when the user exits IGV.\n"
	printf "IGV and samtools are required to run this function. The function\n"
	printf "will install these packages if they're not installed yet.\n"
	printf "This function only accepts fasta and fastQ files as reference genomes\n"
	printf "and sam or bam files as alignment files. These files can be specified\n"
	printf "as parameters. The user will be asked for the files by the program if\n"
	printf "these parameters are missing. This script only works with absolute paths!\n"
	printf "The working directory moves automaticly to ~/ so don't add ~/ to the path.\n"
	printf "The program won't work if there are spaces in one of the directory names.\n"
	printf "If IGV or samtools are not installed yet, an internet connection is required.\n"
	printf "${bold}Usage:${normal}\n"
	printf "  ./functie.sh -a fileA.sam -a fileB.bam -f refgen.fasta\n"
	printf "  ./functie.sh -a fileA.sam -a fileB.bam -g hg18\n"
	printf "  ./functie.sh -a fileA.sam -a fileB.bam -b\n"
	printf "  ./functie.sh -h\n"
	printf "  ./functie.sh\n"
	printf "${bold}Options:${normal}\n"
	printf "  -h\n"
	printf "	  Show usage information\n"
	printf "  -f\n"
	printf "	  Enter the path to the reference genome after this option. This option\n"
	printf "	  may not be empty and it has to be used in combination with -a.\n"
	printf "	  It's not possible to use -f and -g at the same time.\n"
	printf "  -g \n"
	printf "	  Use a reference genome from IGV. The codes can be found on this website:\n"
	printf "	  http://software.broadinstitute.org/software/igv/Genomes. It is not\n"
	printf "	  possible to use -g and -f at the same time. This option may not be empty\n"
	printf "	  and has to be used in combination with -a. Internet connection is required\n"
	printf "	  for this option.\n"
	printf "  -a \n"
	printf "	  Add a path to an alignment file after this option. This option can be\n"
	printf "	  used multiple times. This option may not be empty and it has to be used\n"
	printf "	  in combination with -f and -g.\n"
	printf "  -b \n"
	printf "      Sort or convert and sort an alignment file to a BAM file. IGV won't be started\n"
	printf "      and the sorted bam file won't be deleted.\n"
	printf "${bold}Dependencies:${normal}\n"
	printf "  -IGV 2.0\n"
	printf "  -samtools-0.1.19\n"
	printf "${bold}Authors: ${normal}Jasper van Dalum, Jasper Ouwerkerk, Paul de Raadt,\n"
	printf "Tjardo Maarsveen & Giovanni van Donge\n"
	printf "${bold}Version 6.1					Dec 21 2017${normal}\n"
	exit
}

function convbam {
	if [ $NUMARGS -ge 3 ]; then
		:
	else
		listIndex=(0)
		while [ "1" == "1" ]; do
			read -p "Please enter the absolute path to the alignment file (.sam/.bam) or press enter to continue. " -i "" -e alignment
			if [ -z "$alignment" ]; then
				echo ""
				break
			fi
			if [ -f ${alignment} ]; then
				alignmentList[listIndex]="$alignment"
				let listIndex+=1
			else
				echo "File "$alignment" does not exist!"
			fi
		done
	fi
	listIndex=(0)
	declare -a fileTypeList
	for i in "${alignmentList[@]}"; do
		filetype=$(file -b -i ${i} | awk -F "=" '{print $2}')
		if [ ${filetype} == "binary" ]; then
			fileType='BAM'
			echo "Sorting bam file"
			samtools sort ${i} ${i}_sorted
		else
			fileType='SAM'
			echo "Converting to sorted bam file"
			samtools view -bS ${i} -o ${i}.bam
			samtools sort ${i}.bam ${i}_sorted
			rm ${i}.bam
		fi
		fileTypeList[listIndex]="$fileType"
		let listIndex+=1
	done
	exit
}

cd
NUMARGS=$#
if [ $NUMARGS -ge 1 ]; then
	a=true
	f=true
	g=true
	b=true
	listIndex=(0)
	declare -a alignmentList
	while getopts a:f:g:bh FLAG; do
		case $FLAG in
			a)
				a=false
				alignmentList[listIndex]=$OPTARG
				let listIndex+=1
				;;
			f)
				command -v igv >/dev/null 2>&1 || { echo >&2 "IGV is required to run this script but it's not installed!"; sudo add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) universe multiverse"; sudo apt-get update; sudo apt install igv;}
				command -v samtools >/dev/null 2>&1 || { echo >&2 "Samtools is required to run this script but it's not installed!"; sudo add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) universe multiverse"; sudo apt-get update; sudo apt install samtools;}
				noIGVRefGen=true
				f=false
				refgen=$OPTARG
				;;
			g)
				command -v igv >/dev/null 2>&1 || { echo >&2 "IGV is required to run this script but it's not installed!"; sudo add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) universe multiverse"; sudo apt-get update; sudo apt install igv;}
				command -v samtools >/dev/null 2>&1 || { echo >&2 "Samtools is required to run this script but it's not installed!"; sudo add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) universe multiverse"; sudo apt-get update; sudo apt install samtools;}
				noIGVRefGen=false
				refgen=$OPTARG
				g=false
				;;
			b)
				command -v samtools >/dev/null 2>&1 || { echo >&2 "Samtools is required to run this script but it's not installed!"; sudo add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) universe multiverse"; sudo apt-get update; sudo apt install samtools;}
				b=false
				;;
			h)
				help
				;;
			\?)
				echo -e \\n"Option -$OPTARG not allowed."
				help
				;;
		esac
	done
	shift $((OPTIND-1))
	for i in "${alignmentList[@]}"; do
		if [ ! -f ${i} ]; then
			echo "File "$i" does not exist!"
			exit			
		fi
	done
	if [[ ! -f ${refgen} && ${f} = false ]]; then
		echo "File "$refgen" does not exist!"
		exit
	fi
	if [ $g = false ]; then
		wget -q -O- http://igv.broadinstitute.org/genomes/genomes.txt | grep -v "<Server-Side Genome List>" | awk '{printf "%d\t%s\n", NR, $0}' > genomelist.txt
		cat genomelist.txt | awk -F "\t" '{print $4}' | grep -x "$refgen"
		if [[ "$refgen" != $(cat genomelist.txt | awk -F "\t" '{print $4}' | grep -x "$refgen") ]]; then
			echo "$refgen is not available on the IGV server."
			rm genomelist.txt
			exit
		else
			rm genomelist.txt
		fi
	fi
	if [ $b = false ]; then
		convbam
	fi
	if [[ ( $a = true && $f = true ) || ( $a = true && $g = true ) || ( $g = false && $f = false ) || ($NUMARGS -lt 4) ]]; then
		echo "Please enter the filenames after the options!"
		echo "If you want to use the parameters you have to specify the alignment file(s)"
		echo "and the reference genome! It's not possible to use some combinations of parameters."
		help
	fi
else
	command -v igv >/dev/null 2>&1 || { echo >&2 "IGV is required to run this script but it's not installed!"; sudo add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) universe multiverse"; sudo apt-get update; sudo apt install igv;}
	command -v samtools >/dev/null 2>&1 || { echo >&2 "Samtools is required to run this script but it's not installed!"; sudo add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) universe multiverse"; sudo apt-get update; sudo apt install samtools;}
	echo ""
	echo "Enter * to load a genome from the IGV server. An internet connection is required!"
	echo "Enter # to only convert a sam/bam file to a sorted bam file without starting IGV."
	read -p "Please enter the path to the reference genome (.fasta/.fastq) or * or #: " -i "" -e refgen
	noIGVRefGen=true
	if [[ -f ${refgen} ]]; then
		file="valid"
	else
		if ( [[ "${refgen}" != '*' ]]  && [[ "${refgen}" != '#' ]] ); then
			echo "File "$refgen" does not exist!"
			exit
		fi
	fi
	if [ "${refgen}" == "*" ]; then
		wget -q -O- http://igv.broadinstitute.org/genomes/genomes.txt | grep -v "<Server-Side Genome List>" | awk '{printf "%d\t%s\n", NR, $0}' > genomelist.txt
		printf "%-5s %-38s %-25s\n" "NR" "Organism" "Code"
		cat genomelist.txt | awk -F "\t" '{printf "%-5s %-38s %-25s\n", $1, $2, $4}'
		while [ "1" == "1" ]; do
			read -p "Please enter the number of the genome you want to use: " -i "" -e nr
			refgen=$(head -${nr} genomelist.txt | tail -1 | awk -F "\t" '{print $4}')
			if [[ ${nr} -le $(cat genomelist.txt | wc -l) && ${nr} -gt 0 ]]; then
				break
			else
				echo "Invalid input. Please enter a valid number."
			fi
		done
		rm genomelist.txt
		noIGVRefGen=false
	elif [ "${refgen}" == "#" ]; then
		convbam
	fi
	listIndex=(0)
	while [ "1" == "1" ]; do
		read -p "Please enter the path to the alignment file (.sam/.bam) or press enter to continue. " -i "" -e alignment
		if [ -z "$alignment" ]; then
			echo ""
			break
		fi
		if [ -f ${alignment} ]; then
			alignmentList[listIndex]="$alignment"
			let listIndex+=1
		else
			echo "File "$alignment" does not exist!"
		fi
	done
fi
if [ "$noIGVRefGen" == true ]; then
	if [[ $(sed '3q;d' ${refgen}) == "+"* ]]; then
		echo "Converting fastQ to fasta"
		cat ${refgen} | awk '{if(NR%4==1) {printf(">%s\n",substr($0,2));} else if(NR%4==2) print;}' > ${refgen}
	fi	
	echo "Creating indexed fasta"
	samtools faidx ${refgen}	
fi
listIndex=(0)
declare -a fileTypeList
echo new > batchscript
for i in "${alignmentList[@]}"; do
	filetype=$(file -b -i ${i} | awk -F "=" '{print $2}')
	if [ ${filetype} == "binary" ]; then
		fileType='BAM'
		echo "Sorting bam file"
		samtools sort ${i} ${i}_sorted
		echo "Creating bam index"
		samtools index ${i}_sorted.bam ${i}_sorted.bai
		echo load ${i}_sorted.bam >> batchscript
	else
		fileType='SAM'
		echo "Converting to sorted bam file"
		samtools view -bS ${i} -o ${i}.bam
		samtools sort ${i}.bam ${i}_sorted
		echo "Creating bam index"
		samtools index ${i}_sorted.bam ${i}_sorted.bai
		echo load ${i}_sorted.bam >> batchscript
	fi
	fileTypeList[listIndex]="$fileType"
	let listIndex+=1
done
if [ "$noIGVRefGen" == true ]; then
	igv -b batchscript -g ${refgen}.fai
else
	igv -b batchscript -g ${refgen}
fi
listIndex=(0)
echo "Removing generated files"
for i in "${fileTypeList[@]}"; do
	if [ "${i}" == "SAM" ]; then
		rm "${alignmentList[${listIndex}]}".bam
		rm "${alignmentList[${listIndex}]}"_sorted.bam
		rm "${alignmentList[${listIndex}]}"_sorted.bai
	else
		rm "${alignmentList[${listIndex}]}"_sorted.bam
		rm "${alignmentList[${listIndex}]}"_sorted.bai
	fi
	let listIndex+=1
done
rm batchscript
if [ "$noIGVRefGen" == true ]; then
	rm ${refgen}.fai
fi
