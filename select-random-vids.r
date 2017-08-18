set.seed(20170816)

vidlist <- read.csv('all_4d_vids.csv', header = F)

nvids <- dim(vidlist)[1]

selected <- sample(1:nvids, 100)

vidlist$select <- 0
vidlist$select[selected] <- 1

names(vidlist) <- c('path_on_hpc','selected')

write.csv(vidlist[vidlist$selected==1,],'selected_4d_nii.csv', row.names = F)
