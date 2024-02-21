library(tidyverse)
library(ips)

args = commandArgs(trailingOnly=TRUE)

Ref_file <- args[1]
Var_LIST <- args[2] ## listfile
Var_LIST <- scan(Var_LIST,what="character")
outfile  <- args[3]


Ref_file<-read.FASTA(Ref_file)


K<-1
for(FILENAME in Var_LIST)
{

Var_file <- read.FASTA(FILENAME)

T<-ips::mafft(Ref_file,Var_file,op=10,method="retree 1",maxiterate=10)

Ref      <- as.character(T)[1,]
Var_file <- as.character(T)[2,]
gapPos<-grep("-",Ref)
Idx<-rep(1,length(Var_file))
Idx[gapPos]<-0
new_Idx <- cumsum(Idx)

TEST <- tibble(idx=new_Idx,Ref=Ref,Alt=Var_file)
insertion_site<-unique(TEST$idx[duplicated(TEST$idx)])

if(length(insertion_site)>0)
{
	tmp2 <- tibble()
	for(i in insertion_site)
	{
		tmp<-TEST %>% dplyr::filter(idx %in% i)
		tmp<- tmp %>% mutate(Ref=ifelse(Ref=="-","",Ref))
		id1<-unique(tmp$idx)
		ref<-paste0(tmp$Ref,collapse="")
		alt<-paste0(tmp$Alt,collapse="")
		tmp<-tibble(idx=id1,Ref=ref,Alt=alt)
		if(dim(tmp2)[1]==0) {tmp2<-tmp} else {tmp2 <- bind_rows(tmp2,tmp) }
	}
	TEST <- TEST %>% dplyr::filter(!idx %in% insertion_site)
	TEST <- bind_rows(TEST,tmp2) %>% arrange(idx)

}

message(paste0(K,"/",length(Var_LIST),": writing ",paste0(outfile,"/",basename(FILENAME))))
TEST<-TEST %>% dplyr::filter(Ref != Alt)
#TEST <- TEST %>% dplyr::filter(idx>55, idx<29837)
write_tsv(TEST,paste0(outfile,"/",basename(FILENAME)))
K<-K+1
}
