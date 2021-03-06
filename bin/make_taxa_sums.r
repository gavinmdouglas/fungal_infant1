#Parses taxa_table to make proper taxa summary plots
#inputs are the taxa table and the subset you need for plotting


#Assign taxa colors

#Assign taxa colors
taxa_cols <- sample(cols2(length(rownames(taxa_table))))
names(taxa_cols) <- rownames(taxa_table)
taxa_cols <- c(taxa_cols, "#d3d3d3")
names(taxa_cols)[nrow(taxa_table)+1] <- "Other"


make_taxa_sums <- function(taxa_table, subset_test){
  #Keep only samples from that bodysite, day and from Vaginal and Csection
  subset_otu <- taxa_table[,subset_test]
  #convert to RA
  subset_otu <- sweep(subset_otu,2,colSums(subset_otu),`/`)
  subset_otu <- as.data.frame(t(subset_otu))
  
  #if less than 8%, set to 0 and change name to other
  for(i in 1:ncol(subset_otu)){
    for(k in 1:nrow(subset_otu)){
      if(subset_otu[k,i] < 0.20){
        subset_otu[k,i] <- 0
      }
    }
  }
  #Keep only taxa present (remove 0 counts)
  subset_otu <- subset_otu[,colSums(subset_otu) > 0]
  
  subset_otu$Other <- 0
  #Set other to be the counts subtracted earlier
  for(v in 1:nrow(subset_otu)){
    subset_otu[v,"Other"] <- 1 - rowSums(subset_otu[v,])
  }
  
  #Find taxa present at highest numbers
  subset_otu_na <- subset_otu[,1:ncol(subset_otu)-1]
  subset_otu_na[subset_otu_na == 0] <- NA
  max_abund <- colMeans(subset_otu_na, na.rm=TRUE)
  names(max_abund) <- colnames(subset_otu_na)
  max_abund <- c(max_abund, 0)
  names(max_abund)[length(max_abund)] <- "Other"
  max_abund <- sort(max_abund, decreasing=TRUE)
  
  #add sample IDs to otu table and melt table
  subset_otu <- subset_otu[,names(max_abund)]
  subset_otu$SampleID <- rownames(subset_otu)
  
  otu <- melt(subset_otu, id.vars = "SampleID", variable.name = "Taxa", value.name = "Relative_Abundance")
  
  #Merge metadata
  otu <- merge(otu, mapping, by="SampleID")
  
  #Assign taxa levels (order in bar plot)
  otu$Taxa <- factor(otu$Taxa, levels = c(names(max_abund)), ordered=TRUE)
  
  otu <- otu[order(otu$Taxa),]
  return(otu)
}
