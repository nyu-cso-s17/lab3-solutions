#!/usr/bin/perl
#
# Generate lab/solution hand-out trees from master ossrc tree.
# Usage: mklab.pl lab# sol# outdir files
# - lab# is the lab number: 1, 2, 3, etc.
# - sol# is the solution set number: 1, 2, 3, etc.
# - outdir is the name of the directory into which to export the tree.
# - files is the complete set of source files to (potentially) copy.
#
# Blocks of text demarked with ///LABn are included
# only if the lab number is greater than or equal to 'n'.
# Blocks of text demarked with ///SOLn are included
# only if the solution set number is greater than or equal to 'n'.
#
# Symbols such as UCLALAB are also understood.
# UCLALAB is true iff the current git branch is ucla.
# Allowable branch names are the current git branches plus UCLA.
#

# This script is originally from MIT JOS, and has been slightly modified
# for use in some Spring 2016 CS201 @ NYU labs.

my($branchrex, $onbranch) = ("|NYU", "");
open(BRANCHES, "(git branch --no-color || echo) 2>/dev/null |");
while (<BRANCHES>) {
	if (/^(\*?)\s*(\S+)/) {
		my($b) = $2;
		$b =~ s/-/_/;
		$b =~ s/\W//;
		$b = uc($b);
		$branchrex .= "|" . $b;
		$onbranch = $b if $1 eq "*";
	}
}
close(BRANCHES);

sub dodir {
	my $dirname = shift;
	opendir(DIR, "$dirname");
	my @files = readdir(DIR);
	foreach my $f (@files) {
		if ($f ne ".." && $f ne ".") {
			dofile("$dirname/$f");
		}
	}
	closedir(DIR);
}

# Expression parsing: Handle expressions like "LAB >= 4 || NYULAB >= 3".

sub ltrim ($) {
    my($text) = @_;
    $text =~ s:\A\s+::;
    $text;
}

my(%COMPARATORS) = ("==" => 2, "!=" => 5, "<" => 1, ">" => 4, ">=" => 6, "<=" => 3);

sub eval_condition_term ($) {
    my($text) = @_;
    $text = ltrim($text);

    # Special cases: we know how to handle, but doesn't fit LAB/SOL plan
    if ($text =~ /\A\(/) {
	return eval_condition_expr(substr($text, 1), 1);
    } elsif ($text =~ /\Adefined\s*\(?\s*ENV_(\w+)\s*\)?(.*)\z/) {
	return [defined($ENV{$1}) && $ENV{$1}, $2];
    }

    my($prefix, $symbol, $test, $compar);
    if ($text =~ /\Adefined\s*\(?\s*($branchrex)(LAB|SOL)(\d+)\s*\)?(.*)\z/) {
	($prefix, $symbol, $test, $compar, $text) = ($1, $2, $3, ">=", $4);
    } elsif ($text =~ /\A($branchrex)(LAB|SOL)(\d+)(.*)\z/) {
	($prefix, $symbol, $test, $compar, $text) = ($1, $2, $3, ">=", $4);
    } elsif ($text =~ /\A($branchrex)(LAB|SOL)\s*([!=><]=|[<>])\s*(\d+)(.*)\z/) {
	($prefix, $symbol, $test, $compar, $text) = ($1, $2, $4, $3, $5);
    } elsif ($text =~ /\A($branchrex)(LAB|SOL)((?:\z|\W).*)\z/ && $1 ne "") {
	($prefix, $symbol, $test, $compar, $text) = ($1, $2, 1, ">=", $3);
    } elsif ($text =~ /\A(?:0x)?0+((?:\z|\W).*)\z/) {
	return [undef, $1, 0];
    } elsif ($text =~ /\A(?:0x)?0*[1-9a-fA-F][0-9a-fA-F]*((?:\z|\W).*)\z/) {
	return [undef, $1, 1];
    } else {
	return [undef, $text];
    }

    my($val) = ($symbol eq 'LAB' ? $labno : $solno);
    my($bit) = ($val == $test ? 2 : ($val < $test ? 1 : 4));
    my($result) = ($COMPARATORS{$compar} & $bit) != 0;
    $result = 0 if $prefix ne "" && $prefix ne $onbranch;
    return [$result, $text];
}

sub eval_condition_notexpr ($) {
    my($text) = @_;
    $text = ltrim($text);
    if ($text =~ /\A\!/) {
	my($x) = eval_condition_notexpr(substr($text, 1));
	if (defined($x->[0])) {
	    $x->[0] = !$x->[0];
	} elsif (@$x == 3) {
	    $x->[2] = !$x->[2];
	}
	return $x;
    } else {
	return eval_condition_term($text);
    }
}

sub eval_condition_andexpr ($) {
    my($text) = @_;
    my($any_answer, $answer, $undef_text) = (undef, undef, undef);
    while (($text = ltrim($text)) ne "") {
	if (defined($any_answer) && $text =~ /\A\&\&/) {
	    $text = substr($text, 2);
	} elsif (defined($any_answer)) {
	    last;
	}
	my($x) = eval_condition_notexpr($text);
	if (defined($x->[0])) {
	    $answer = (defined($answer) ? $answer && $x->[0] : $x->[0]);
	    $any_answer = 1;
	    $text = $x->[1];
	} elsif (@$x == 3) {
	    $answer = (defined($answer) ? $answer && $x->[2] : $x->[2]);
	    $any_answer = 0 if !defined($any_answer);
	    $undef_text = $text if !defined($undef_text);
	    $text = $x->[1];
	} else {
	    return $x;
	}
    }
    return $any_answer ? [$answer, $text] : [undef, $undef_text];
}

sub eval_condition_expr ($$) {
    my($text, $nest) = @_;
    my($answer) = undef;
    while (($text = ltrim($text)) ne "") {
	if ($text =~ /\A\)/ && $nest) {
	    return [$answer, substr($text, 1)];
	} elsif (!defined($answer) || $text =~ /\A\|\|/) {
	    $text = substr($text, 2) if defined($answer);
	    my($x) = eval_condition_andexpr($text);
	    if (defined($x->[0])) {
		$answer = (defined($answer) ? $answer || $x->[0] : $x->[0]);
		$text = $x->[1];
	    } else {
		return $x;
	    }
	} else {
	    last;
	}
    }
    return [$answer, $text];
}

sub check_condition ($$;$$) {
    my($condition, $text, $filename, $inlines) = @_;
    # remove comments
    $text =~ s:\*/\s*\z:: if $condition =~ m:\A/*:;
    while ($text =~ m:\A(.*?)(/[/*]|[#])(.*)\z:) {
	$text = $1;
	if ($2 eq "/*") {
	    my($rest) = $3;
	    $rest =~ s:\A.*?\*/::;
	    $text .= $rest;
	}
    }
    # "ifdef" special handling
    if ($condition eq "ifdef" || $condition eq "#ifdef") {
	$text = "defined(" . $text . ")";
    } elsif ($condition eq "ifndef" || $condition eq "#ifndef") {
	$text = "!defined(" . $text . ")";
    }
    # evaluate answer
    my($answer) = eval_condition_expr($text, 0);
    if (defined($answer->[0]) && ltrim($answer->[1]) eq "") {
	return $answer->[0];
    } else {
	return undef;
    }
}

sub dofile {
	my $filename = shift;

	if (-d $filename) {
		dodir($filename);
		return;
	}

	my $ccode = 0;
	if ($filename =~ /.*\.[ch]$/) { $ccode = 1; }
	my $tmpfilename = "$filename.tmp";

	open(INFILE, "<$filename") or die "Can't open $filename";
	open(OUTFILE, ">$tmpfilename") or die "Can't open $tmpfilename";
	chmod(((stat($filename))[2] & 07777), $tmpfilename);

	my $outlines = 0;
	my $inlines = 0;
	my $expectedinline = 1;
	my $lastgood = "NO LAST GOOD";
	my %stack;
	my $depth = 0;
	my $answer;
	$stack{$depth}->{'emit'} = 1;

	while(<INFILE>) {
		my $line = $_;
		chomp;
		$inlines++;
		$emit = $stack{$depth}->{'emit'};
		if (m:^([#]?ifdef|[#]?ifndef|[#]elif|[#]if|/\*#if|/\*#elif)\s+(.*?)\s*$:
		    && defined(($answer = check_condition($1, $2, $filename, $inlines)))) {
			$conditional = $1;
			if ($conditional !~ /el/) {
				$stack{++$depth} = { 'anytrue' => 0, 'isours' => 1 };
			}
			$stack{$depth}->{'emit'} = ($stack{$depth-1}->{'emit'} && $answer);
			if ($conditional =~ /el/) {
				$stack{$depth}->{'emit'} &&= !$stack{$depth}->{'anytrue'};
			}
			$stack{$depth}->{'anytrue'} ||= $answer;
			$emit = 0;
			$lastgood = $line;
		} elsif (m:^([#]if|ifdef|ifndef|ifeq|ifneq):) {
			# Other conditions we just pass through
			++$depth;
			$stack{$depth} = { 'isours' => 0, 'emit' => $stack{$depth-1}->{'emit'} };
			$lastgood = $line;
		} elsif (m:^(/\*[#]|[#]|)else:) {
			if ($stack{$depth}->{'isours'}) {
				$emit = 0;
				$stack{$depth}->{'emit'} = ($stack{$depth-1}->{'emit'} && !$stack{$depth}->{'anytrue'});
			}
			$lastgood = $line;
		} elsif (m:^(/\*[#]|[#]|)endif:) {
			if ($stack{$depth}->{'isours'}) {
				$emit = 0;
			}
			--$depth;
			if ($depth < 0) {
				die("unmatched endif on line $filename:$inlines \"$line\"");
			}

		}

		if ($emit) {
			if ($solno > 0 && $ccode &&
			    $expectedinline != $inlines) {
				$expectedinline = $inlines;
			}
			print OUTFILE "$_\n";
			$outlines++;
			$expectedinline++;
		}
	}

	if ($depth != 0) {
		print STDERR "warning: unmatched #if/#ifdef/#elif/#else/#endif in $filename\n";
		print STDERR "last known good line: $filename:$inlines $lastgood\n";
	}

	close INFILE;
	close OUTFILE;

	# After doing all that work, nuke empty files
	if ($outlines) {
		my $outfilename = "$outdir/$filename";

		# Create the directory the output file lives in.
		$_ = $outfilename;
		s|[/][^/]*$||g;
		system("mkdir", "-p", $_);

		# Move the temporary file to the correct place.
		rename($tmpfilename, $outfilename);
	} else {
		unlink $tmpfilename;
	}
}

sub usage {
	print STDERR "usage: mklab <labno> <solno> <outdir> <srcfiles...>\n";
	exit(1);
}

if (@ARGV < 3) {
	usage();
}

$labno = shift(@ARGV);
$solno = shift(@ARGV);
$outdir = shift(@ARGV);

if ($labno < 1 || $solno !~ /^0|[1-9][0-9]*$/) {
	usage();
}

# Create a new output directory.
if (!(-d $outdir)) {
	mkdir($outdir) or die "mkdir $outdir: $!";
}

# Populate the output directory
foreach $i (@ARGV) {
	dofile($i);
}
