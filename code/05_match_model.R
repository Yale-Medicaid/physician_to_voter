library(tidyverse)
library(arrow)

load("../data/mid_join_dataset.Rda")

phys_data <- read_parquet("../data/cleaned_physician_data.parquet")  %>%
	mutate(
		full_name = tolower(paste0(provider_first_name, provider_middle_name, `provider_last_name_(legal_name)`)),
		full_name_no_mid = tolower(paste0(provider_first_name, `provider_last_name_(legal_name)`)),
		st = tolower(replace_na(provider_business_mailing_address_state_name, "")),
		st_mi = tolower(paste0(replace_na(substr(provider_middle_name,1,1),""),st)), 
	) %>%
	rename(
		zip = provider_business_mailing_address_postal_code,
		frst_nm = provider_first_name,
		mid_nm = provider_middle_name,
		last_nm = `provider_last_name_(legal_name)`
	)

stopifnot(all(processed$npi == comparison_dataset$npi))

matches <- logical(nrow(comparison_dataset))
for (i in 1:nrow(comparison_dataset)) {
	if (!is.na(processed$year_dist[i]) & (processed$year_dist[i] < 21 | processed$year_dist[i] > 40)) {
		next
	} else if (!grepl("(Unknown|Medical)", processed$CommercialData_Occupation[i])) { 
		next
	}
	
	if (!is.na(processed$CommercialData_Occupation[i]) && processed$CommercialData_Occupation[i] == "Medical-Physician") {
		matches[i] <- TRUE 
	} else if (!is.na(processed$year_dist[i]) & (processed$year_dist[i] > 25 & processed$year_dist[i] < 32)) { 
		if (!is.na(comparison_dataset$zip_dist[i]) && comparison_dataset$zip_dist[i] <= 50 && processed$n[i] <= 5  ) {
			matches[i] <- TRUE 
		} else if(processed$n[i] == 1)  { 
			matches[i] <- TRUE
		}
	} else if (!is.na(comparison_dataset$zip_dist[i]) && comparison_dataset$zip_dist[i] <= 20 && processed$n[i] <= 5 ) { 
			matches[i] <- TRUE
	} else if (processed$n[i] == 1){ 
			matches[i] <- TRUE
	}
}

matched <- bind_cols(
	processed, 
	comparison_dataset %>% select(zip_dist)
)[matches, ]

write_parquet(matched, "../data/matched_data.parquet")


#is.na(phys_data$grd_yr) %>% mean()

# bind_cols(
# 	processed, 
# 	comparison_dataset %>% select(zip_dist)
# )[matches, ] %>%
# 	ungroup() %>%
# 	ggplot(aes(x=year_dist)) + 
# 	geom_histogram(bins=100) + 
# 	xlab("Years Between Birth and Med School Graduation") + 
# 	ylab("Count") 
# 
# mean(is.na(matched$zip_dist))
# mean(is.na(matched$year_dist))
# 
# mean(is.na(comparison_dataset$zip_dist))
# mean(is.na(comparison_dataset$year_dist))
# 
# #mean(is.na(processed$grd_yr))
# 
# cleaned_physican_data <- read_parquet("../data/cleaned_physician_data.parquet")
# 
# nppes_state_tally <- cleaned_physican_data %>%
# 	filter(nchar(provider_business_mailing_address_state_name)==2) %>%
# 	group_by(provider_business_mailing_address_state_name) %>%
# 	summarize(n=n())
# 
# joined_tally <- processed[matches, ] %>%
# 	group_by(Residence_Addresses_State) %>%
# 	summarize(n_joined=n())
# 
# inner_join(nppes_state_tally, joined_tally, by = c("provider_business_mailing_address_state_name" = "Residence_Addresses_State")) %>%
# 	mutate(n_2 = n) %>%
# 	pivot_longer(c(n, n_joined)) %>%
# 	mutate(name = ifelse(name == "n", "Number of Doctors in NPPES", "Number of Linked Doctors")) %>%
# 	ggplot(aes(x=reorder(provider_business_mailing_address_state_name,n_2), fill = name, y = value)) + 
# 	geom_bar(stat = "identity", position = "dodge") + 
# 	coord_flip() + 
# 	xlab("State") + 
# 	ylab("Number")
# 	
# 	
# inner_join(nppes_state_tally, joined_tally, by = c("provider_business_mailing_address_state_name" = "Residence_Addresses_State"))  %>%
# 	ggplot(aes(x=n, y=n_joined)) + 
# 	geom_text(aes(label = provider_business_mailing_address_state_name))
# matches <- read_csv("../data/matched.csv") %>%
# 	pull(matched)
# 
# #sampled <- sample(unique(comparison_dataset$npi),200)
# #save(sampled, file="../data/sampled_ids.Rda")
# 
# comparison_dataset$l2  <- processed$LALVOTERID
# 
# training_data <- comparison_dataset %>% 
# 	mutate(match_id = paste0(npi, l2)) %>%
# 	to_duckdb() %>%
# 	filter(npi %in% sampled) %>%
# 	select(-npi, -l2) %>%
# 	group_by(match_id) %>%
# 	summarize_all(list(mean=mean,min=min)) %>%
# 	collect() %>%
# 	mutate(match = match_id %in% matches)  %>%
# 	select(-match_id)
# 
# forest_out <- ranger(match ~ ., data = training_data, probability=T)
# preds <- predict(forest_out, training_data)
# 
# out_data <- comparison_dataset %>% 
# 	to_duckdb() %>%
# 	group_by(npi,l2) %>%
# 	summarize_all(list(mean=mean, min=min)) %>%
# 	collect() 
# 
# out_data$pred_match <- predict(forest_out, out_data)$predictions[,1]
# out_data$match_id <- paste0(out_data$npi, out_data$l2)
# 
# predicted_matches <- out_data$match_id[out_data$pred_match < .8]
# processed$match_id <- paste0(processed$npi, processed$LALVOTERID)
# processed_pred_match <- processed[processed$match_id %in% predicted_matches, ]
# 
# hist(processed_pred_match$year_dist)
# mean(processed_pred_match$medical[!processed_pred_match$na_medical])
# 
# 	head(processed_pred_match,400) %>% view()
# 
# mean(processed_pred_match$year_dist[processed_pred_match$CommercialData_Occupation == "Medical-Physician"],na.rm=T)
# mean(processed_pred_match$year_dist[processed_pred_match$CommercialData_Occupation == "Medical-Nurse"],na.rm=T)
# 
