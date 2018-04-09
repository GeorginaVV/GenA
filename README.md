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

The final output is a multifasta with the sequences in nucleotides with their names in their headers. 



  -Housekeeping Genes according to Gil 2004. 
  
  -Housekeeping Genes in the Vibrionaceae family.
  
  -MLSA scheme used for the Vibrionaceae family.
  
   

# Marker_Finder.pl
Marker_Finder sorts the possible markers, and gives it as an output file with the sequences in the same order. This file has only one header with the corresponding input file name.

# Citation
Soon to be published. I hope.
