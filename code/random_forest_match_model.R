# 
classify_match_nonmatch_rf <- function(lshed_data, labelled_file) {
	load(labelled_file)	
	
	agree_mat <- cbind(
		as.integer(ifelse(lshed_data$full_name_sim > .95, 4, ntile(lshed_data$full_name_sim,4) - 1)),
		as.integer(lshed_data$mid_initial_agree),
		as.integer(lshed_data$mid_name_agree),
		as.integer((ntile(-lshed_data$n,5))-1),
		as.integer(replace_na(as.integer(5-ntile(lshed_data$zip_dist,5)),5)),
		as.integer(lshed_data$medical),
		as.integer(replace_na(ntile(-abs(lshed_data$year_dist-27),10),0)),
		replace_na(as.integer(as.factor(lshed_data$CommercialData_EstimatedHHIncome)),0),
		replace_na(as.integer(as.factor(lshed_data$CommercialData_Education)),0),
		replace_na(as.integer(lshed_data$Voters_Gender == "M"),2)
	)
	
	frst <- grf::probability_forest(agree_mat[labelled[,1],], as.factor(labelled[,2]))
	rf_preds <- predict(frst, agree_mat)$predictions[,2]
	lshed_data$match_prob <- rf_preds
	
	# Do not use this - we no longer use naive bayes
	
	# guess <- rep(.5, nrow(lshed_data))
	# guess[labelled[,1]] <- ifelse(labelled[,2],.95,.05)
	# 
	# nb_preds <- zoomerjoin:::em_link(agree_mat, guess, tol = 10^-6,max_iter = 500)
	# lshed_data$nb_match_prob <- nb_preds
	# 
	# print("nb found the following # of matches:")
	# print(round(sum(lshed_data$nb_match_prob)))
	
	print("rf found the following # of matches:")
	print(round(sum(lshed_data$match_prob)))
	
	
	#return(lshed_data)
	return(filter(lshed_data, rf_preds > .5))
}

