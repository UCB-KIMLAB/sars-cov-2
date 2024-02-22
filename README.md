# sars-cov-2

codes for sars-cov-2 analysis

## Requirements

`tidyverse` and `ips` package are requiring to run `varcall.R` code

## Data preprocessing

### Goals for DATA manipulation
- Remove individual specific variants which we do not interests. Those may result of processing bias (base error etc).
- Filter out the sequences which occur to rare. Those may output of bias.

### dividing fasta files into single accessions

```bash
  perl fasta.divider.pl <fasta file/gzipped fasta file> <output folder> ## divide fasta files into individual files
```
### NTs statistics are calculated by followng scripts.

```bash
  perl fasta.char.stat.pl $(ls *) > NTS_stats.tsv ## count nts statistics
```

the output, `NTS_stats.tsv` is a headerless tab-separated values files containing following 3 columnes :

| Accession	 | NTs | n    |
| ---------- | --- | ---- |
| LC529905.1 |	G	 | 5864 |
| LC529905.1 |	T	 | 9596 |
| LC529905.1 |	A	 | 8954 |
| LC529905.1 |	C	 | 5489 |
| MN938384.1 |	G	 | 5859 |
| MN938384.1 |	C	 | 5484 |
| ...        | ... | ...  |

- the output, character.stats, were manipulated by tidyverse package` in R.
- 2-letter or 3-letter codes are considered as Ambiguous letter counted in column nAMB.
- genome size ratio (gRATE) is the ratio against Wuhan-1 (29,903 bps)

## outlier checks 

```{R}
    library(tidyverse)
    df <- read_tsv("NTS_stats.tsv",col_names=c("accession","NTs","n"))
    df <- df %>% spread(NTs,n,fill=0) %>% mutate(nAMB=B + D + H + K + M + R + S + V + W + Y) %>%   ## make new column which has counts of non-ACGT character
                                          select(-B,-D,-H,-K,-M,-R,-S,-V,-W, -Y) %>%               ## removing nts columns
                                          mutate(SIZE=A+C+G+T+nAMB,CG=C+G) %>%                     ## calculate genome size and # of CG
                                          mutate(GCRatio=CG/SIZE,gRATE=SIZE/29903)                 ## calculating GCratio and genome size ratio
    summary(df$gRATE)
    
    ## calculate IQR
    QT1 <- summary(df$gRATE)[2]
    QT3 <- summary(df$gRATE)[5]
    IQR <- QT3-QT1
    upperboundary <- QT3 + (3 * IQR)
    lowerboundary <- QT1 - (3 * IQR)
    
    ## check genome size outliers
    df <- df %>%  mutate(outlier=ifelse(gRATE > upperboundary | gRATE < lowerboundary, TRUE,FALSE))   
    
    ## calculate IQR
    QT1 <- summary(df$GCRatio)[2]
    QT3 <- summary(df$GCRatio)[5]
    IQR <- QT3-QT1
    upperboundary <- QT3 + (3 * IQR)
    lowerboundary <- QT1 - (3 * IQR)
    
    df <- df %>% mutate(GCR_outlier=ifelse(GCRatio > upperboundary | GCRatio < lowerboundary, TRUE,FALSE)) %>%
            select(accession,A,C,G,T,nAMB,SIZE,gRATE,outlier,GCRatio,GCR_outlier) %>% rename("gSIZE"="SIZE","gSIZE_outlier"="outlier","gSIZE_ratio"="gRATE")
            
    write_tsv("char.stat-2022-04-14.tsv") ## save file

```

### Pangolin Lineage determination

```bash
  cat * > ../FILE.fa
  pangolin FILE.fa --outfile FILE.lineage.csv
```

## Variant calling

This is R code, named `varcall.R`, which read fasta file and align it to given reference sequence and write `.tsv` file contaiing position, Reference Allele, and Alternative Allele.

```bash
  Rscript varcall.R <Reference> <variant file list> <outfile folder>
```
## Onehot encoding

```bash
  Rscript varcall2Onehot.R <FILELIST> <OUTFILE>
```
