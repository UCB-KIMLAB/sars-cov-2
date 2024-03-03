#!/usr/bin/perl

use strict;

my $filename="";
my $fheader="";
my $fbody="";
my $oDIR=$ARGV[1];
my $line=0;

print $oDIR;

#open IN,'<',zcat $ARGV[0];
open IN,'<',$ARGV[0];


while(<IN>)
{
	chomp($_);
	$line=$line+1;

	if($_ =~ m/^\>/)
	{

		if($filename ne "") {
			open FH,">",$oDIR."/".$filename or die $!;
			print FH $fheader."\n".$fbody;
			#print STDERR $oDIR."/".$filename,"\n";
			close(FH);
		}
			my @tmparr=split(/[\|\s]/,$_);
			$filename = substr($tmparr[0],1,length($tmparr[0]));
			#$filename = $tmparr[3];
			$filename =~ s/^\s+|\s+$//g;
			$filename =~ tr/\//\./;
			$filename =~ s/: /:/g;
			$filename =~ tr/ /_/;
			$fheader = $_;
			$fbody = "";
			#print $filename,"\r";

	} else {
		$fbody=$fbody.$_."\n";
	}

}

## print last one after printing all.
open FH,">",$oDIR."/".$filename or die $!;
print FH $fheader,"\n",$fbody;
print STDERR $oDIR."/".$filename,"\n";
close(FH);
