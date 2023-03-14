#devtools::install_github("beniaminogreen/zoomerjoin")
library(zoomerjoin)
library(arrow)
library(tidyverse)
library(lubridate)
library(zipcodeR)

yale_schema <- c(
	CommercialData_Occupation = "c",
	CommercialData_OccupationGroup = "c",
	CommercialData_OccupationIndustry = "c",
	County = "c", 
	EthnicGroups_EthnicGroup1Desc = "c",
	Ethnic_Description = "c",
	FECDonors_AvgDonation = "n",
	FECDonors_AvgDonation_Range = "c",
	FECDonors_LastDonationDate = "c",
	FECDonors_NumberOfDonations = "n",
	FECDonors_PrimaryRecipientOfContributions = "c",
	FECDonors_TotalDonationsAmount = "n",
	FECDonors_TotalDonationsAmt_Range = "c",
	Parties_Description = "c",
	Residence_Addresses_CensusTract	= "c",
	Voters_Age = "n",
	Voters_BirthDate = "c",
	Voters_Gender = "c"
)

datavant_schema <- c(
	Residence_Addresses_State = "c",
	Residence_Addresses_Zip = "c",
	Residence_Addresses_ZipPlus4 = "c",
	Voters_Age = "n",
	Voters_BirthDate = "c",
	Voters_FirstName = "c",
	Voters_Gender = "c",
	Voters_LastName = "c",
	Voters_MiddleName = "c",
	Voters_NameSuffix = "c"
)

combined_schema <- c(LALVOTERID  = "c", yale_schema, datavant_schema)

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

voter_files <- list.files("../data/processed_voter_data/", full.names = T, recursive = T)

voter_dataset <- open_dataset(voter_files)  %>%
	select(LALVOTERID, contains("Voters_"), 
				 Residence_Addresses_Zip,Residence_Addresses_State, 
				 Residence_Addresses_City, contains("Occupation"), 
				 any_of(names(combined_schema))
				 ) %>%
	collect() %>%
	mutate(
		full_name = tolower(paste0(Voters_FirstName, replace_na(Voters_MiddleName, ""), Voters_LastName)), 
		full_name_no_mid_l2 = tolower(paste0(Voters_FirstName, Voters_LastName)), 
		st_2 = replace_na(tolower(Residence_Addresses_State),""), 
		st_mi_2 = tolower(paste0(replace_na(substr(Voters_MiddleName,1,1),""),replace_na(Residence_Addresses_State,""))), 
		medical = grepl("Medical", CommercialData_Occupation, ignore.case = T),
		na_medical = is.na(CommercialData_Occupation) | CommercialData_Occupation == "Unknown",
		medical_sub = ifelse(grepl("Medical", CommercialData_Occupation, ignore.case = T),CommercialData_Occupation, "None")
	)


join_out_1 <- lsh_inner_join(phys_data, voter_dataset, block_by = c("st"= "st_2"),
													 n_gram_width=4, band_width = 12, n_bands = 300, threshold=.75)

join_out_2 <- lsh_inner_join(phys_data, voter_dataset, 
														 by = c("full_name_no_mid" = "full_name_no_mid_l2"), block_by = c("st_mi"= "st_mi_2"),
													 n_gram_width=4, band_width = 12, n_bands = 300, threshold=.75)
	

join_out <- bind_rows(join_out_1, join_out_2) %>%
	distinct()

print("Finished Joining")

processed <- join_out %>%
	mutate(
		Voters_MiddleName = replace_na(Voters_MiddleName, ""),
		mid_nm = replace_na(mid_nm, ""), 
		year_dist = grd_yr - year(Voters_BirthDate),
	) %>%
	group_by(npi) %>%
	mutate(n = n()) 

comparison_dataset <- 
	tibble(
		full_name_sim = jaccard_similarity(processed$full_name.x, processed$full_name.y, 3), 
		state_agree = processed$st == processed$st_2,
		mid_initial_agree = tolower(substr(processed$mid_nm,1,1)) == tolower(substr(processed$Voters_MiddleName,1,1)),
		mid_name_agree = jaccard_similarity(tolower(processed$mid_nm), tolower(processed$Voters_MiddleName)),
		phys_mid_name_len = nchar(processed$mid_nm),
		voters_mid_name_len = nchar(processed$Voters_MiddleName),
		zip_dist = zip_distance(
			substr(processed$zip,1,5),
			substr(processed$Residence_Addresses_Zip,1,5)
		)[,3], 
		year_dist = processed$grd_yr - year(processed$Voters_BirthDate),
		n = processed$n,
		medical = processed$medical,
		na_medical = processed$na_medical, 
		medical_sub = processed$medical_sub, 
		npi = processed$npi
	)

save(comparison_dataset,  processed, file="../data/mid_join_dataset.Rda")