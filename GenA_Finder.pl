#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Std;

#GenA_Finder
#Version 1.3
#Dependencies: Prodigal, Blastp, Vsearch (optional)
#Options-------------------------------------------------------------------------------------------

my %options = ();
getopts( "hq:vd:m", \%options );
my $HELP = (
    "USAGE
   script [-h] [-q FILENAME] [-v USE VSEARCH] [-d PATH TO DATABASE] \n
-----------------------------------------------------------
This script uses assembled fasta sequences as input file.
If you want to use a personal database, you must declare the path to the database.
The script will ask for the desired database if not declared.\n
The Script will use blastp for default, if -v option is not declared.\n
\n"
);
print "$HELP" if defined $options{h};
exit 0 if defined $options{h};
my $search = ();
$search = ("vsearch") if defined $options{v};
$search = ("blastp")  if not defined $options{v};
my $file = ("$options{q}") if defined $options{q};
my @tag = ();

#Selection of files--------------------------------------------------------------------------------------
print "\n";
print "This script uses fasta files with the contigs of an assembled genome.\n";
print "This genome will be compared to the desired database.\n";
print "\n";
my @fastafiles = ();
if ($file) {
    print "\n";
    print "These are the files the script will work with:\n";
    print "\n";
    print $file, "\n";
    push @fastafiles, $file;
    print "\n";
}
else {
    foreach my $file ( glob("*.fasta") ) {
        push @fastafiles, $file;
    }

    if (@fastafiles) {
        print "Make sure these are the fasta files you want to process.\n";
        print "\n";
        print "--------------------------------------\n";
        foreach my $file (@fastafiles) {
            print $file, "\n";
        }
        print "--------------------------------------\n";
        print "\n";
        print "Are these the correct files? (y/n)\n";
        my $response = <STDIN>;
        if ( $response =~ /^[Y]?$/i ) {
            print "\n";
            print "\n";
        }
        elsif ( $response =~ /^[N]?$/i ) {
            print "\n";
            print "Check your fasta files for errors.\n";
            exit 0;
        }
    }
    else {
        print "$HELP";
        print "ERROR:\n";
        print "	The script couldn't find fasta files to process\n";
        exit 0;
    }
}

#Selection of Database-----------------------------------------------------------------------------------
my @pathtodb = ();
my $pdb = ("$options{d}") if defined $options{d};
if ($pdb) {
    print "This is the path of the database the script will be working with:\n";
    print $pdb, "\n";
    print "\n";
    push @pathtodb, $pdb;
}
else {
    print "Choose your database:\n";

    sub menu {
        for ( ; ; ) {
            print "--------------------\n";
            print "$_[0]\n";
            print "--------------------\n";
            for ( my $i = 0 ; $i < scalar( @{ $_[1] } ) ; $i++ ) {
                print $i + 1, "\.\t ${ $_[1] }[$i]\n";
            }
            print "\n?: ";
            my $i = <STDIN>;
            chomp $i;
            if ( $i && $i =~ m/[0-9]+/ && $i <= scalar( @{ $_[1] } ) ) {
                return ${ $_[1] }[ $i - 1 ];
            }
            else {
                print "\nInvalid input.\n\n";
            }
        }
    }
    my @databases = (
        "Housekeeping genes according to Gil",
        "Housekeeping genes of the Vibrionaceae Family",
        "MLSA scheme"
    );
    my $db = menu( 'Database Options', \@databases );
    print "\n";
    if ( $db eq "MLSA scheme" ) {
        push @tag, "MLSA";
        if ( $search eq "vsearch" ) {
            print "The database: ", $db, " has been chosen\n";
            push @pathtodb, "~/GenA/MLSA/MLSA_nucleotides";
        }
        else {
            print "The database: ", $db, " has been chosen\n";
            push @pathtodb, "~/GenA/MLSA/MLSA";

        }
    }
    elsif ( $db eq "Housekeeping genes according to Gil" ) {
        push @tag, "HGAG";
        if ( $search eq "vsearch" ) {
            print "The database: ", $db, " has been chosen\n";
            push @pathtodb, "~/GenA/HG/HG_nucleotides";
        }
        else {
            print "The database: ", $db, " has been chosen\n";
            push @pathtodb, "~/GenA/HG/HG";
        }
    }
    elsif ( $db eq "Housekeeping genes of the Vibrionaceae Family" ) {
        push @tag, "HGVF";
        if ( $search eq "vsearch" ) {
            print "The database: ", $db, " has been chosen\n";
            push @pathtodb, "~/GenA/HGV/HGV_nucleotides";
        }
        else {
            print "The database: ", $db, " has been chosen\n";
            push @pathtodb, "~/GenA/HGV/HGV";
        }
    }
}

#Searching with Prodigal-------------------------------------------------------------------------------------------------
foreach my $files (@fastafiles) {
    print "Prodigal is working with:\n";
    print "		", $files, "\n";
    my @cmd = "prodigal -a $files.faa -d $files.fna -i $files -q > output.txt";
    system(@cmd);
    print "\n";
    unlink "output.txt";
    my $fa = substr( $files, 0, -6 );
    my @noderemover =
"awk '/^>/{\$0=\">NODE_\"++i\"_contig\"}1' $files.fna > $fa.fna | awk '/^>/{\$0=\">NODE_\"++i\"_contig\"}1' $files.faa > $fa.faa";
    system(@noderemover);
    unlink "$files.fna", "$files.faa";
}
print "\n";
print "Prodigal is done.\n";
print "Don't close the terminal\n";
print "\n";

#Comparison with the Database of choice --------------------------------------------------------------------
my @proteinquery = ( glob("*.faa") );
foreach my $query (@proteinquery) {
    print "comparing ", $query, " to the database.\n";
    my $qa = substr( $query, 0, -4 );
    foreach my $path (@pathtodb) {
        my @vsearch = (
"vsearch --usearch_global $qa.fna -blast6out $qa.tab -db $path --id 0.2 --threads 4"
        );
        my @blastp = (
"blastp -db $path -query $query -out $qa.tab -evalue 1e-5 -outfmt 6 -num_threads 5"
        );
        system(@vsearch) if defined $options{v};
        system(@blastp)  if not defined $options{v};
    }
}

#Get the best query of the bunch ---------------------------------------------------------------------------
print "\n";
print "looking for the best matches of the query.\n";
my @tabquery = ( glob("*.fna") );
foreach my $qa (@tabquery) {
    my $qac = substr( $qa, 0, -4 );
    my @sorteocmd =
      "awk '{print \$1, \$2, \$3}' $qac.tab | sort -k 3 -n -r -o sorted$qac";
    system(@sorteocmd);
    rename( "sorted$qac", "$qac.tab" ) || die("Error in renaming");
    my @eleccioncmd = "sort -k 2,2 -u -o sorted$qac $qac.tab";
    system(@eleccioncmd);
    rename( "sorted$qac", "$qac.tab" ) || die("Error in renaming");
    my @contigcmd =
"awk '{print \$1}' $qac.tab > contigs_$qac.tab | awk '{print \$1, \$2}' $qac.tab > names_$qac.tab";
    system(@contigcmd);
    print "\n";
    print "looking for the nucleotide sequences in $qac fna file.\n";
    my $filename = ("contigs_$qac.tab");
    open( my $fh, $filename )
      or die "Can't open file '$filename";

    while ( my $row = <$fh> ) {
        chomp $row;
        my @linesearch = "sed -n '/>$row/,/>/p' $qac.fna | wc -l > $row.txt";
        system(@linesearch);
        my $linename = ("$row.txt");
        open( my $lh, $linename )
          or die "Can't open file '$linename";
        while ( my $line = <$lh> ) {
            chomp $line;
            my $numberoflines = ( $line - 2 );
            my @sequences_search =
              "grep $row -A $numberoflines $qac.fna > $row.fa";
            system(@sequences_search);
        }
        unlink "$row.txt";
    }
    my @processed =
      "touch sequences_$qac.tab | cat *.fa >> sequences_$qac.tab | rm *.fa";
    system(@processed);
    my $seqname = "names_$qac.tab";
    open( my $sn, $seqname )
      or die "Can't open file '$seqname";
    while ( my $row = <$sn> ) {
        chomp $row;
        my ( $node, $name ) = split( / /, $row );
        my @renamer = "sed -i s/$node/$name/g sequences_$qac.tab";
        system(@renamer);
    }

    #Final Output.
    foreach my $tag (@tag) {

        rename( "sequences_$qac.tab", "FinalOutput_$tag$qac.fasta" );
        print "\n";
        print "The output of ", $qac, ".fasta can be found if the folder Final_Output\n",
        print "\n";
        print "The Identity Score is in $qac.tab. \n"
          if not defined $options{v};
        print "\n";

    }
}
my @delete = "rm names* contigs* | mkdir Final_Output | mv FinalOutput_*.fasta Final_Output/";
system(@delete);
