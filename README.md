Scripts done for my thesis.

# GenA_Finder.pl
Version 1.3
GenA_Finder translates and compares assembled genomes in fasta format to the selected database. The final output is a multifasta with the sequences in nucleotides with their names in their headers. 

# Databases
  -Housekeeping Genes according to Gil 2004. 
  -Housekeeping Genes in the Vibrionaceae family. 
  -MLSA scheme used for the Vibrionaceae family.
   
The default comparison tool is blastp, but you can use vsearch for a quicker search.

# Marker_Finder.pl
Marker_Finder sorts the possible markers, and gives it as an output file with the sequences in the same order. This file has only one header with the corresponding input file name.

# Installation
Dependencies: blastp, prodigal, vsearch (optional).
Make sure you download the repository in Home.
Test genome and expected results are in Test folder.

# Citation
Soon to be published. I hope.
