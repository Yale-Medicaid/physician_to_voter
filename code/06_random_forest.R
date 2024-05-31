library(tidyverse)
library(grf)
library(arrow)
library(targets)

make_X_matrix <- function(df) {
	df <- df %>% 
		mutate(med_prof = grepl("Medical", CommercialData_Occupation)) %>% 
		select(zip_dist, year_dist, full_name_sim, mid_initial_agree, mid_name_agree, n)
	
	 model.matrix.lm(~-1 + ., df, na.action=na.pass)
}


add_rf_match_predictions_to_df <- function(labelled_training_files, lshed_data){
	labelled_training_data <- labelled_training_files %>% 
		map_df(read_parquet)
	
	training_X <- make_X_matrix(labelled_training_data)
	training_Y <- as.factor(labelled_training_data$match)
	
	model <- probability_forest(training_X, training_Y)
	
	
	X <- make_X_matrix(lshed_data)
	lshed_data$match <- predict(model, newdata=X)$predictions[,2]
	
	return(lshed_data)	
}



