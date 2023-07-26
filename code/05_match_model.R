# This is our hand-coded Decision tree to determine matches / non-matches
# I am not confident in the performance of this method - it's mostly meant to be 
# Defensible to Economists. Also provides a nice point of comparison to the Random Forest Methods. 
descision_tree_matcher <-  function(lshed_data) { 
	matches <- logical(nrow(lshed_data))
	for (i in 1:nrow(lshed_data)) {
		if (!is.na(lshed_data$year_dist[i]) & (lshed_data$year_dist[i] < 21 | lshed_data$year_dist[i] > 40)) {
			next
		} else if (!grepl("(Unknown|Medical)", lshed_data$CommercialData_Occupation[i])) { 
			next
		}
		
		if (!is.na(lshed_data$CommercialData_Occupation[i]) && lshed_data$CommercialData_Occupation[i] == "Medical-Physician") {
			matches[i] <- TRUE 
		} else if (!is.na(lshed_data$year_dist[i]) & (lshed_data$year_dist[i] > 25 & lshed_data$year_dist[i] < 32)) { 
			if (!is.na(lshed_data$zip_dist[i]) && lshed_data$zip_dist[i] <= 50 && lshed_data$n[i] <= 5  ) {
				matches[i] <- TRUE 
			} else if(lshed_data$n[i] == 1)  { 
				matches[i] <- TRUE
			}
		} else if (!is.na(lshed_data$zip_dist[i]) && lshed_data$zip_dist[i] <= 20 && lshed_data$n[i] <= 5 ) { 
				matches[i] <- TRUE
		} else if (lshed_data$n[i] == 1){ 
				matches[i] <- TRUE
		}
	}
	
		lshed_data[matches,]
}



