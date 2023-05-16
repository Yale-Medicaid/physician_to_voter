add_nb_probabilities <- function(lshed_data) {
	inv_logit <- function(x) {
		exp(x)/(1+exp(x))
	}
	
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
	
	rs <- rowSums(agree_mat[,1:7])
	guesses <- inv_logit((rs-mean(rs))/sd(rs))

	out <- zoomerjoin:::em_link(agree_mat, guesses, tol = 10^-4,max_iter = 500)
	
	lshed_data$match_prob <- out
	
	head(lshed_data)
	
	print("found the following # of matches:")
	print(round(sum(out)))
	
	lshed_data[lshed_data$match_prob > .5,]
}

