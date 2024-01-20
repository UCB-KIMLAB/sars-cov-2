#!/usr/env perl

use strict;
use warnings;

my %hash;

for(my $i=0;$i<=$#ARGV;$i++)
{

my $infile=$ARGV[$i];

if($infile =~ /\.gz$/) { open IN, '-|', 'gunzip','-c',$infile; }
else { open IN,'<',$infile;}

#open IN, '-|', 'gunzip','-c',$infile;
#open IN,'<',"zcat $infile |";
my $sample;

while(<IN>)
{
        chomp($_);
	if($_ =~ /^>/) {
		$sample=substr($_,1,length($_));
		my @tmparr=split(" ",$sample);
		$sample=$tmparr[0];
	} else {
                my @arr=split(//,$_);
                for(my $i=0;$i<=$#arr;$i++)
                {
                        if(exists($hash{$sample}{$arr[$i]})) {$hash{$sample}{$arr[$i]}++;}
                        else {$hash{$sample}{$arr[$i]}=1;}
                }
        }
}
}
close(IN);

foreach my $key (keys %hash)
{
	foreach my $key2 (keys %{$hash{$key}})
	{
        print $key,"\t",$key2,"\t",$hash{$key}{$key2},"\n";
	}
}
