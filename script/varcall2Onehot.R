library(tidyverse)
library(progress)
#LIST <- list.files("./")
args = commandArgs(trailingOnly=TRUE)

LIST <- args[1]
OUT  <- args[2]

LIST<-scan(LIST,what="character")

clean_deletion <- function(x) {
  df2.1<-x %>% dplyr::filter(Alt!="-")
  df2.2<-x %>% dplyr::filter(Alt=="-")
  if(dim(df2.2)[1]==0) {return(x)}
  GapPos<-x %>% dplyr::filter(Alt=="-") %>% pull(idx)
  chkContinuousGap<-GapPos[-length(GapPos)] == GapPos[-1] -1
  GAPSTARTPOSITION <- c(GapPos[1],GapPos[c(FALSE,!chkContinuousGap)])
  GAPENDPOSITION   <- c(GapPos[!chkContinuousGap],GapPos[length(GapPos)])
  df2.2$block<-NA
  for(i in 1:length(GAPSTARTPOSITION)) {
    df2.2<-df2.2 %>% mutate(block=ifelse(idx>=GAPSTARTPOSITION[i] & idx<=GAPENDPOSITION[i],i,block))
  }
  df2.2<-df2.2 %>% group_by(block) %>% summarize(idx=min(idx),Ref=paste(Ref,collapse=""),Alt=paste(Alt,collapse="")) %>% select(-block)
  y<-bind_rows(df2.1,df2.2) %>% arrange(idx)
  return(y)
}

pb <- progress_bar$new(total = length(LIST))
si<-tibble()
for(i in LIST)
{
  pb$tick()
  df<-read_tsv(i,show_col_types = FALSE)
  df <- clean_deletion(df)
  if(is.logical(df$Ref)) {
    df$Ref<-tolower(as.character(df$Ref)) %>% substr(1,1)
  }
  if(is.logical(df$Alt)) {
    df$Alt<-tolower(as.character(df$Alt)) %>% substr(1,1)
  }

  if(dim(df)[1]!=0) {

#  df<-df %>% dplyr::filter(stringi::stri_length(Ref)==1,stringi::stri_length(Alt)==1) %>% mutate(taxon=basename(i),Var=paste0(Ref,idx,Alt)) %>% select(-Ref,-idx,-Alt)
   df<-df %>% mutate(taxon=basename(i),Var=paste0(Ref,idx,Alt)) %>% select(-Ref,-idx,-Alt)
  } else {
  df <- tibble(taxon=basename(i),Var="NO_VARIANT")
  }
  si <- bind_rows(si,df)
}

si <- si %>% mutate(n=1) %>% spread(Var,n,fill=0)
if("NO_VARIANT" %in% colnames(si))
{
si <- si %>% select(-NO_VARIANT)
}

write_tsv(si,OUT)
