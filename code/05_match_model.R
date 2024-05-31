#' Decision Tree Matcher
#'
#' @description This is our hand-coded Decision tree to determine matches / non-matches
#' I am not confident in the performance of this method - it's mostly meant to be 
#' Defensible to Economists. Also provides a nice point of comparison to the Random Forest Methods. 
#'
#' @param lshed_data A dataframe of possible matches, as returned by the `locality_sensitive_hash` function
#' 
#' @return a dataframe of physicians with the matching voter records
descision_tree_matcher <-  function(lshed_data) { 
	matches <- logical(nrow(lshed_data))
	for (i in 1:nrow(lshed_data)) {
		match_status <- FALSE
		
		# Cannot be a match if the Physician has a med school graduation year and birth
		# date recorded, and if they would have graduated at less than 21 or more than 40. 
		# Also, do not match if they have a commercial occupation in the L2 data that
		# is not "Unknown", or does not include the phrase "Medical"
		if (!is.na(lshed_data$year_dist[i]) & (lshed_data$year_dist[i] < 21 | lshed_data$year_dist[i] > 40)) {
			next
		} else if (!grepl("(Unknown|Medical)", lshed_data$CommercialData_Occupation[i])) { 
			next
		}
		
		# Consider a match if the voter is recorded as being a physician in the L2 dataset
		if (!is.na(lshed_data$CommercialData_Occupation[i]) && lshed_data$CommercialData_Occupation[i] == "Medical-Physician") {
			match_status <- TRUE 
		} else if (!is.na(lshed_data$year_dist[i]) & (lshed_data$year_dist[i] > 25 & lshed_data$year_dist[i] < 32)) {  # OR if they graduated between 25-32 AND 
			if (!is.na(lshed_data$zip_dist[i]) && lshed_data$zip_dist[i] <= 50 && lshed_data$n[i] <= 5  ) { # Practice within 50 miles of their adddress and have an uncommon name 
				match_status <- TRUE 
			} else if(lshed_data$n[i] == 1)  {  # Practice within 50 miles of their adddress
				match_status <- TRUE
			}
		} else if (!is.na(lshed_data$zip_dist[i]) && lshed_data$zip_dist[i] <= 20 && lshed_data$n[i] <= 5 ) { # OR if they practice within 20 miles of their address AND they have an uncommon name (fewer than 5 possible matches)
				match_status <- TRUE
		} else if (lshed_data$n[i] == 1){  # OR if there is only one name that is close to theirs
				match_status <- TRUE
		}
		
		matches[i] <- match_status
	}
	
		lshed_data[matches,]
}



