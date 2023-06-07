#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

peaks <- read.csv(args[1], stringsAsFactors = F, header = F, sep = '\t')

med <- median(peaks$V3 - peaks$V2) #359
peaks_med <- peaks
colnames(peaks_med)[1] <- 'Chr'
peaks_med$Start <- peaks_med$V2+peaks_med$V10-round((med/2))
peaks_med$End <- peaks_med$V2+peaks_med$V10+round((med/2))
peaks_med$GeneID <- rownames(peaks_med)
peaks_med$Strand <- '+'

write.table(peaks_med[,c('GeneID', 'Chr', 'Start', 'End', 'Strand')], file = args[2], quote = F, sep = '\t', col.names = T, row.names = F)
