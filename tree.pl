#!/usr/bin/perl
#recursive algorithm biology deliverable
#tree traverse pass to a “string” and a “depth”
#Running Script: perl -e “script name”

use strict;
use warnings;
no warnings 'recursion';

my $filename = $ARGV[0]; #consider getting input filename from $ARGV[0], like the input ID below
my $input_ID = $ARGV[1] or $input_ID = 0;
my $treestring; # my $input_ID = $ARGV[1] or $input_ID = 0; this gets input ID from command line, and if not sets it to '0' to print everything
main(); # to determine depth of $input_ID, add: my $input_depth = 0; my $ID_min = 0; while (input_ID > $ID_min) { $ID_min += $ID_min + 2**$input_depth; $input_depth++; }
my $input_depth = 0; 
my $ID_min = 0; 
	while ($input_ID > $ID_min) {
	$ID_min += $ID_min + 2**$input_depth; 
	$input_depth++; 
	}

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
	$depth++;
	my $enable_print = 0;
	# remove this increment (removed: $depth++;) to ensure that root node has depth = 0; instead, assign node ID: my node_ID = 0;
	my $node_ID = 0;
	# before printing anything (removed: print "(";	)), check that we are at the proper depth, and if so 2) we have a matching node ID, then enable printing: if ($enable_print == 0 && $depth == $input_depth && $node_ID == $input_ID) { $enable_print = 1; }
	#current branch is everything within the outermost parentheses
	$current_branch = $1; # add: my $node_A_ID = $node_ID + 2**$depth; my $node_B_ID = $node_ID + 2**($depth+1);
	my $node_A_ID = $node_ID + 2**$depth; 
	my $node_B_ID = $node_ID + 2**($depth+1);
	($node_A_ID, $node_B_ID) = branch_splitter($current_branch); 
	node_reader($node_A_ID, $depth); # also pass $node_A_ID as third argument and $enable_print as fourth
	# (removed: print ",";) be sure to check notes on line 27
	node_reader($node_B_ID, $depth); # also pass $node_B_ID as third argument and $enable_print as fourth
	# (removed: print ")100;\n"; )be sure to check notes on line 27
	if ($enable_print == 0 && $depth == $input_depth && $node_ID == $input_ID) { 
		$enable_print = 1; 
	}
}

# opens file, reads tree
sub main {
	open (FILE, $filename); 
	$treestring=<FILE>; 
}

# subroutine for node analysis; works with one node at a time
sub node_reader {
	my $current_branch = shift;
	my $depth = shift; # add my $node_ID = shift; my $enable_print = shift;
	my $node_ID = shift; 
	my $enable_print = shift;
	# grab branch length and bootstraps; $1 contains branches, $2 contains bp value, $3 contains length
	if ($current_branch =~ /^\((.*)\)(\d+):([\de\.\+]+)$/) {
		$depth++; # add: if ($enable_print == 0 && $depth == $input_depth && $node_ID == $input_ID) { $enable_print = 1; }
		print "("; # be sure to check notes on line 27
		my $current_branch = $1;
		my $bootstrap = $2;
		my $branchlength= $3; # add: my $node_A_ID = $node_ID + 2**$depth; my $node_B_ID = $node_ID + 2**($depth+1);
		my $node_A_ID = $node_ID + 2**$depth; 
		my $node_B_ID = $node_ID + 2**($depth+1);
		($node_A_ID, $node_B_ID) = branch_splitter($current_branch);
		node_reader($node_A_ID, $depth); # also pass $node_A_ID as third argument and $enable_print as fourth
		# (removed: print ",";)be sure to check notes on line 27
		node_reader($node_B_ID, $depth); # also pass $node_B_ID as third argument and $enable_print as fourth
		# (removed: print ")$bootstrap:$branchlength";)be sure to check notes on line 27
		if ($enable_print == 0 && $depth == $input_depth && $node_ID == $input_ID) { 
		$enable_print = 1; 
		}
	}
	# detects if current branch leads to a leaf and stops recursion
	if ($current_branch =~ /^([$chars]*)/) {
		$depth++; # add: if ($enable_print == 0 && $depth == $input_depth && $node_ID == $input_ID) { $enable_print = 1; }
		my $leaf = $1;
		# (removed: print "$leaf";) be sure to check notes on line 27
		if ($enable_print == 0 && $depth == $input_depth && $node_ID == $input_ID) {
			$enable_print = 1; 
			}
		return $leaf, $depth;
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

sub significant {
	my $current_branch = shift;
	my $depth = shift;
	# grab branch length and bootstraps; $1 contains branches, $2 contains bp value, $3 contains length
	if ($node_A_ID) {
		if ($node_A_ID =~ /^(\d+):([\de\.\+]+)$/) {
		$depth++;
		my $bootstrap = $1;
		my $branchlength = $2;
		my $sig_bp == 80 >= $bootstrap;
		if ($enable_print == 0 && $depth == $input_depth && $node_ID == $input_ID) {
			$enable_print = 1; 
			}
		}
	}
	if ($node_B_ID) {
		if ($node_B_ID =~ /^(\d+):([\de\.\+]+)$/) {
		$depth++;
		my $bootstrap = $1;
		my $branchlength = $2;
		my $sig_bp == 80 >= $bootstrap;
		if ($enable_print == 0 && $depth == $input_depth && $node_ID == $input_ID) {
			$enable_print = 1; 
			}
	}
}
