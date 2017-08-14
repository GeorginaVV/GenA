#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Std;

#Marker_Finder

print "The script can make a file with the found markers.\n";
print "This file will be ready to align for a phylogenetic analysis.\n";
print "\n";
print "This part of the script will sort the genes in the Final Output file.\n";
print "This may take a while.\n";
print "\n";
my @GenIdQuery = ( glob("FinalOutput_*.fasta") );
my $condition = 1000;

#Looking for the minimum of genes-----------------------------------------------------------------------------
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
			} 
	}

#Looking for the names of the genes---------------------------------------------------------------------------
	print "The Minimum number of genes in common found was:	", $condition,".\n";
	print "The script will sort these genes in alphabetical order.\n";
	print "\n";
	print @MinimumGenes,"\n";
	foreach my $MinimumGenes (@MinimumGenes){
	my @SortingGenes = "awk '{print \$2}' $MinimumGenes.tab > GenName1 | sort GenName1 >> GenNames";
		system (@SortingGenes);	}
	unlink ("GenName1");

#Looking for the genes in the FinalOutput file----------------------------------------------------------------
my $idnames    = "GenNames";
my @id         = ();
my $searcherQuery = ();

foreach my $FinalSequence (@GenIdQuery) {
	my $FinalName = substr( $FinalSequence, 16, -6 );
	print "Working with:	\n";
	print "	",$FinalName,"\n";
#La busqueda de los genes se hace en esta parte, pero por alguna razon a veces no encuentra todos. Asi que se tiene que el numero de genes sea el mismo. 	
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
			unlink ("Ready_$FinalName.fasta");
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

