n <- 1000

comp_data <- tar_read(lshed_data) %>% 
	select(full_name.x, full_name.y, zip_dist, year_dist, n, CommercialData_Occupation)

ids <- c()
match <- c()
for (i in 1:n) {
	print(paste("iteration", i, "out of", n))
	
	id <- sample(1:nrow(lshed_data), 1)
	ids <- c(ids,id)
	print(comp_data[id,])
	match <- c(match, tolower(readline()) == "y")
}

ids <- ids[1:400]
match <- match[1:400]
labelled <- cbind(ids, match)
save(labelled, file = "data/hand_coded.Rda")

frst <- grf::probability_forest(agree_mat[ids,], as.factor(labelled[,2]))
grf_preds <- predict(frst, agree_mat)$predictions[,2]
