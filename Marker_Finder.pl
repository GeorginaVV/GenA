#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Std;

#Marker_Finder Options and Start ------------------------------------------------------------------------------
my %options = ();
getopts( "hg:", \%options );
my $condition = 1000;
my $GENES = ("$options{g}") if defined $options{g};
my $HELP = (
"    USAGE
   script [-h] [-g FILE OF THE ORDER OF GENES (NOT RECOMMENDED)] \n
-----------------------------------------------------------
This script uses the files named as FinalOutput as input files.
With this, the script makes a file with the found markers. \n
\n
If a file with the name and the order of genes is not given, the script will make one. 
For this it will find the number of genes that all input files share.
If a gene is not shared by all, this genes will not be included in the final file.
\n
The script redoes the file with the markers, until the number of markers is right.
This may take a while.
\n"
);
print "$HELP" if defined $options{h};
exit 0 if defined $options{h};

print "The script can make a file with the found markers.\n";
print "This file will be ready to align for a phylogenetic analysis.\n";
print "\n";
print "This part of the script will sort the genes in the Final Output file.\n";
print "This may take a while.\n";
print "\n";
my @GenIdQuery = ( glob("FinalOutput_*.fasta") );

#If i give file with names and order--------------------------------------------------------------------------	
if (defined $GENES) {
print "WARNING: \n";
print "USING A PERSONAL FILE FOR THE ORDER OF THE GENES CAN BE PROBLEMATIC.\n";
print "IF THE NAME OF THE GEN IS NOT THE SAME IN THE FILE, THE SCRIPT CAN'T FIND AND COMPILE IT. \n";
print "BE WARY OF THIS. THIS IS NOT RECOMMENDED.\n";
	my $count = 0;
	open my $TabQuery, "<", $options{g} or die($!);
	$count++ while <$TabQuery>;
	close $TabQuery;
	$condition = $count;	
}
#If i don't give it ------------------------------------------------------------------------------------------
else {
#Minimum number of genes
my @MinimumGenes = ();
foreach my $AlmostFinal (@GenIdQuery) {
	my $FinalName = substr( $AlmostFinal, 16, -6 );
		my $count = 0;
		open my $TabQuery, "<", "$FinalName.tab" or die($!);
		$count++ while <$TabQuery>;
		close $TabQuery;
		if ( $condition < $count ) { 
			$condition = $condition; 
			}
		else {  
			@MinimumGenes = ();			
			$condition = $count; 
		 	push @MinimumGenes, $FinalName;
			} }
#Names of the genes
	print "The Minimum number of genes in common found was:	", $condition,".\n";
	print "The script will sort these genes in alphabetical order.\n";
	print "\n";
	print @MinimumGenes,"\n";
	foreach my $MinimumGenes (@MinimumGenes){
	my @SortingGenes = "awk '{print \$2}' $MinimumGenes.tab > GenName1 | sort GenName1 >> GenNames";
		system (@SortingGenes);	}
	unlink ("GenName1");
}
#Looking for the genes in the FinalOutput file----------------------------------------------------------------
my @id         = ();
my $searcherQuery = ();
foreach my $FinalSequence (@GenIdQuery) {
	my $FinalName = substr( $FinalSequence, 16, -6 );
	print "Working with:	\n";
	print "	",$FinalName,"\n";		
	my $idnames = ( "$options{g}" ) if defined $options{g};
	   $idnames    = ( glob("GenNames") ) if not defined $options{g};
BUSQUEDA:
	
	open( my $id, $idnames )
	or die "Can't open file '$idnames'";
	while ( my $row = <$id> ) {
		chomp $row;
		push @id, $row;
		my @MarkerSearch= "grep $row -A \$(sed -n '/>$row/,/>/p' $FinalSequence | wc -l) $FinalSequence | head --lines=-2 >> $row.fa";
		my @CatGenes = "touch Ready_$FinalName.fasta | cat $row.fa >> Ready_$FinalName.fasta | rm $row.fa";  				
			system (@MarkerSearch); system (@CatGenes);	} 
#Contar los genes
	my @searcher = "touch number | grep '>' Ready_$FinalName.fasta > number"; system (@searcher);
	my $numberfile = "number";
	my $genecounter = (0);	
	open (my $searcherQuery, $numberfile ) 
	or die "Can't open file '$searcherQuery'";
		$genecounter++ while <$searcherQuery>;
		close $searcherQuery;
		unlink ("number");
	if ( $genecounter =~ $condition ) {
			my @FinalReady = "grep '>' -v Ready_$FinalName.fasta >> AllTogether_$FinalName.fasta";	
			system (@FinalReady);					
			unlink ("Ready_$FinalName.fasta"); 
			my @FinalMarkers= "sed '1 i\ >$FinalName' AllTogether_$FinalName.fasta >> Markers_$FinalName.fasta";
				system (@FinalMarkers);
			unlink ("AllTogether_$FinalName.fasta");	}
	else { 
			$genecounter = (0);
			print "The script didn't look for the marker in the right way.\n";
			print "REDOING\n";
			 goto BUSQUEDA; 
		}
my @alltogethernow = "cat Markers_*.fasta > All_Markers.fasta";
system(@alltogethernow);

open (my $Genes, $idnames) 
	or die "could not open filename";
print "-----------------------------\n";
print "The genes used are as follow:\n";	
	while(<$Genes>) {    
		print $_;	}
print "-----------------------------\n";
close $idnames; }
	
