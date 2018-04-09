Scripts done for Georgina Valdez' master thesis.

# Installation
GenA_Finder.pl Dependencies: perl, prodigal, blast+ and vsearch (optional)

Marker_Finder.pl Dependencies: perl

The cloned folder must be present in Home so the paths in the script are coherent. 
Changes in the permissions must be done with chmod in order to use the scripts.

($chmod 777 GenA_Finder.pl Marker_Finder.pl)


# GenA_Finder.pl
Version 1.3

GenA_Finder.pl runs with at least 4 threads. The script translates and compares assembled genomes in fasta format to the selected database. Input files for this script are fasta of an assembled genome with a coverage 10x. To avoid incomplete hits, the genome can be at contig level as long as there are a maximum of 800 contigs in one file. Use ($~/GenA/GenA_Finder.pl) to call this script (without a symbolic link). 

The script will use all fasta files in the active folder if not declared (-q). Blastp is the default search option if vsearch is not enabled (-v). If you want to use a personal database, you must declare the path to the preferred database (-d). The script will ask for the desired database if not declared. 

The three databases used by default by the script are: Housekeeping genes according to Gil, 2004 (206 genes); Housekeeping Genes in the Vibrionaceae family (163 genes) and a MLSA scheme used for the Vibrionaceae at the realization of the thesis work (13 genes).

The final output for each input fasta is a multifasta with the sequences in nucleotides with their names in their headers and a tab file with each respective name and indentity score. These two files are needed for their use with Marker_Finder.pl.


# Marker_Finder.pl
Version 1.2

Marker_Finder sorts the possible markers, and gives it as an output file with the sequences in the same order. Marker_Finder.pl works with the output files of GenA_Finder.pl located in the active folder. It is imperative to make sure the needed files are in the respective folders. Use ($~/GenA/Marker_Finder.pl) to call this script (without a symbolic link). 

Since it is possible that the files are different gene number, the script finds the minimum number of genes and finds them in each input fasta. This could take a while and multiple retries, but the script will only stop when is all finished correctly. 

The output file has only one header with the corresponding input file name and all the sequences in the correct format to start aligning with the desired alignment tool. If there is more than one file, the script compiles them in its one fasta file called All_Marker.fasta. 

# Citation
Soon to be published. I hope.
