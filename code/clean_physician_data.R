library(tidyverse)
library(arrow)

cms_data <- read_csv("../data/DAC_NationalDownloadableFile.csv") %>%
  rename_with(tolower) %>%
	select(npi, grd_yr) %>%
	distinct()

nppes_data <- read_csv("../data/NPPES_Data_Dissemination_February_2023/npidata_pfile_20050523-20230212.csv") %>%
	rename_with(~tolower(gsub(" ", "_", .x)))

table(nppes_data$entity_type_code)

subset_nppes_data <- nppes_data %>% 
	select(npi, provider_first_name, provider_middle_name, `provider_last_name_(legal_name)`,
				 provider_business_mailing_address_state_name, provider_business_mailing_address_postal_code, 
				 provider_business_mailing_address_state_name, healthcare_provider_taxonomy_code_1, 
				 entity_type_code
				 ) %>%
	drop_na(npi) %>%
	filter(entity_type_code == 1)

nucc_data <- read_csv("../data/nucc_taxonomy_230.csv") %>% 
	rename_with(~tolower(gsub(" ", "_", .x)))

full_data <- left_join(subset_nppes_data, nucc_data, by = c("healthcare_provider_taxonomy_code_1" = "code"))  %>%
	left_join(cms_data, by = "npi")

full_data <- full_data %>% 
	mutate(
		physician = grouping == "Allopathic & Osteopathic Physicians"
	) %>%
	filter(physician) 

full_data %>%
	write_parquet("../data/cleaned_physician_data.parquet")

n_distinct(full_data$npi)
