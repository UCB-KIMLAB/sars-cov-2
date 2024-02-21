# sars-cov-2
sars-cov-2 code for analysis


## data filtering

```bash
  perl fasta.divider.pl <fasta file/gzipped fasta file> <output folder> ## divide fasta files into individual files
  perl fasta.char.stat.pl <input> > <output> ## count nts statistics
```
## variant calling

```bash
  Rscript varcall.R <Reference> <variant file list> <outfile folder>
```

##
