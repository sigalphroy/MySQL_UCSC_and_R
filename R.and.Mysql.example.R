## Script demonstrates Mysql playing nice with R
# Written by Christian Roy
# 02/12/13
# Git change
#Hi,
#I attached what we did today. 
#Your homework is 
#1.) Find the # of transcripts that have introns in hg18.
library(RMySQL) # First load the RMySQL package

# First open hg18 ucsc table browser connection
ucsc.hg18 <- dbConnect(MySQL(), user="genome", password="",
                       dbname="hg18", host="genome-mysql.cse.ucsc.edu")

# Now load the refSeq table
hg18.refSeq <- dbGetQuery(ucsc.hg18, 
                                  "SELECT *
                                  FROM refGene")

# What does the data look like?
colnames(hg18.refSeq)
head(hg18.refSeq$exonCount)

# Now subset the dataframe for those tx with >1 exon (i.e. has intron)
hg18.tx.with.introns <- 
  subset(x=hg18.refSeq,
         subset=hg18.refSeq$exonCount > 1)

# How many rows (transcripts) are there?
nrow(hg18.tx.with.introns)

#2.) Find the # of transcripts that have introns in Yeast.
#To make this;
#For yeast; go to ucsc genome browser->Table Browser; Go clade: other- Find "S.cer mRNAs" under group mRNA and EST Tracks.
#You already know how to get human RefSeq.
#Hint: Use awk and wc commands
ucsc.sacCer3 <- dbConnect(MySQL(), user="genome", password="",
                          dbname="sacCer3", host="genome-mysql.cse.ucsc.edu")

sacCer3.allmRNA <- dbGetQuery(ucsc.sacCer3, 
                              "SELECT * FROM all_mrna")

sacCer3.allmRNA.with.introns <-
  subset(sacCer3.allmRNA,
         subset=sacCer3.allmRNA$blockCount>1)

nrow(sacCer3.allmRNA.with.introns)

rm(list=ls()) # Clear workspace


## now we can make a plot using these skills
### Connect to different databases at UCSC
#Start w/ mm9
ucsc.mm9 <- dbConnect(MySQL(), user="genome", password="",
                         dbname="mm9", host="genome-mysql.cse.ucsc.edu")
# rn4
ucsc.rn4 <- dbConnect(MySQL(), user="genome", password="",
                         dbname="rn4", host="genome-mysql.cse.ucsc.edu")
#hg18
ucsc.hg18 <- dbConnect(MySQL(), user="genome", password="",
                         dbname="hg18", host="genome-mysql.cse.ucsc.edu")

## Now use SQL syntax to query for number of exons per refSeq transcript
#mm9
mm9.refSeq.exons.count <- dbGetQuery(ucsc.mm9, 
                                  "SELECT 
                                  name,name2,exonCount
                                  FROM refGene")
#rn4
rn4.refSeq.exons.count <- dbGetQuery(ucsc.rn4, 
                                  "SELECT 
                                  name,name2,exonCount
                                  FROM refGene")
#hg18
hg18.refSeq.exons.count <- dbGetQuery(ucsc.hg18, 
                                  "SELECT 
                                  name,name2,exonCount
                                  FROM refGene")

#look at the data
head(mm9.refSeq.exons.count)

library(manipulate)

dist.plot <- 
manipulate(
    boxplot(mm9.refSeq.exons.count$exonCount, # mm9 exon counts
            rn4.refSeq.exons.count$exonCount, # rn4 exon counts
            hg18.refSeq.exons.count$exonCount, # hg18 exon counts
            outline=F, # Do not plot outliers
            names=c("mouse","rat","human"), # X-axis labels
            ylab="Number of exons per refSeq transcript", # yaxis labels
            main="Number of exons per RefSeq transcript" # plot title)
      ),
outline = checkbox(FALSE, "Show outliers"),
y.max=slider(min=0,max=1000,initial=25))
grid()



