#!/usr/bin/perl
#recursive algorithm biology deliverable
#tree traverse pass to a “string” and a “depth”
#Running Script: perl -e “script name”

use strict;
use warnings;
no warnings 'recursion';

my $filename = $ARGV[0]; 
my $input_ID = $ARGV[1] || 0;
my $treestring;  
my $node_ID_counter = 0;
main();

# characters expected for leaf names and leaf branch lengths
my $chars = "abcdefghijklmnopqrstuvwxyz";
$chars .= "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
$chars .= "0123456789";
$chars .= "_:+.";

# keeping track of node depth within tree; root node is at ‘0’
my $depth = 0;
my $current_branch; 

# start of the tree traversal is below
# line starts with "(", which indicates root node 
if($treestring =~ /^\((.*)\)100\;$/) {
	#calculating depth for every node, also add variable that regulates printing behavior (false until ID is matched): my $enable_print = 0; subsequently condition every print statement on enable_print "if ($enable_print) { print...; }"
	my $enable_print = 0;
	my $node_ID = $node_ID_counter;
	if ($enable_print == 0 && $node_ID == $input_ID) { 
		$enable_print = 1; 
	}
	if ($enable_print) {
		print "(";
	}
	#current branch is everything within the outermost parentheses
	$current_branch = $1; 
	$node_ID_counter++;
	my $node_A_ID = $node_ID_counter;
	$node_ID_counter++; 
	my $node_B_ID = $node_ID_counter;
	(my $node_A, my $node_B) = branch_splitter($current_branch); 
	node_reader($node_A, $depth, $node_A_ID, $enable_print); 
	node_reader($node_B, $depth, $node_B_ID, $enable_print); 
	if ($enable_print) {
		print ")100;\n";
	}
}

# opens file, reads tree
sub main {
	open (FILE, $filename); 
	$treestring=<FILE>; 
	my $outfilename = "$filename.sig";
	open (SIG_FILE, ">", $outfilename) or die "Did not open outfile";
}

# subroutine for node analysis; works with one node at a time
sub node_reader {
	my $current_branch = shift;
	my $depth = shift; 
	my $node_ID = shift; 
	my $enable_print = shift;
	# grab branch length and bootstraps; $1 contains branches, $2 contains bp value, $3 contains length
	if ($current_branch =~ /^\((.*)\)(\d+):([\de\.\+]+)$/) {
		$depth++; 
		if ($enable_print == 0 && $node_ID == $input_ID) {
			$enable_print = 1; 
		}
		if ($enable_print) {
			print "$node_ID" . "(";
		}
		my $current_branch = $1;
		my $bootstrap = $2;
		my $branchlength= $3; 
		if ($bootstrap >= 80){
			print SIG_FILE "$node_ID,$depth,$bootstrap\n";
		}
		$node_ID_counter++;
		my $node_A_ID = $node_ID_counter;
		$node_ID_counter++; 
		my $node_B_ID = $node_ID_counter;
		my ($node_A, $node_B) = branch_splitter($current_branch);
		node_reader($node_A, $depth, $node_A_ID, $enable_print);
		if ($enable_print) {
			print ",";
		}
		node_reader($node_B, $depth, $node_B_ID, $enable_print); 
		if ($enable_print) {
			print ")$bootstrap:$branchlength";
		}
	}
	# detects if current branch leads to a leaf and stops recursion
	if ($current_branch =~ /^([$chars]*)/) {
		$depth++; 
		my $leaf = $1;
		if ($enable_print == 0 && $node_ID == $input_ID) {
			$enable_print = 1; 
		}
		if ($enable_print) {
			print "$leaf";
		}
	}
}

sub branch_splitter {
	my $current_branch = shift;
	my $char;
	my $split_position;
	my $parenthesis = 0;
	#goes through all characters for position
	for ( my $i = 0; $i < length($current_branch); $i++ ) { 
		$char = substr($current_branch, $i, 1);
		#counts parenthesis and adds 1 for all open ‘(‘ parenthesis
		if ($char eq "(") {
			$parenthesis++;
		}
		#counts parenthesis and subtracts 1 for all closed ‘)‘ parenthesis
		if ($char eq ")") {
			$parenthesis--;
		}
		#when a comma is equal to 0 or between two nodes and recognizes the split of nodes
		if ($char eq "," && $parenthesis == 0) {
			$split_position = $i;
			last;
		}
	}
	#node_A and node_B are splitting the nodes
	my $node_A = substr($current_branch, 0, $split_position);
	my $node_B = substr($current_branch, $split_position+1);
	return $node_A, $node_B;
}
