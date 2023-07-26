library(targets)
library(tarchetypes)

source("code/01_extract_l2.R")
source("code/03_clean_physician_data.R")
source("code/04_locality_sensitive_hash.R")
source("code/05_match_model.R")
source("code/match_diagnostics.R")
source("code/random_forest_match_model.R")


tar_option_set(packages = c("arrow",  "zoomerjoin", "lubridate", "zipcodeR", "tidyverse", 
														"furrr", "digest", "lubridate"
														),
							 garbage_collection = T,
							 )

list(
	# clean physician data
	tar_target(cms_file, "data/DAC_NationalDownloadableFile.csv", format = "file"),
	tar_target(nppes_file, "data/NPPES_Data_Dissemination_February_2023/npidata_pfile_20050523-20230212.csv", format = "file"),
	tar_target(nucc_taxonomy_file, "data/nucc_taxonomy_230.csv", format = "file"),
	
	tar_target(physician_data,clean_physician_data(cms_file, nppes_file, nucc_taxonomy_file), format = "parquet"),
	
	tar_target(voter_files, 
						 process_voter_data(list.files("data/raw_l2", pattern = "*.tab", full.names=T, recursive = T)), 
						 format = "file_fast"
						 ),
	
	# Run LSH To create rough dataset
	tar_target(
		lshed_data, locality_sensitive_hash(physician_data, voter_files),
		format = "parquet"
	),
	
	# Two Methods to take rough data and keep only true matches
	tar_target(labelled_file,"data/hand_coded.Rda", format = "file" ), 
	tar_target(rf_match_data, classify_match_nonmatch_rf(lshed_data, labelled_file), format = "parquet"),
	tar_target(dt_match_data,  descision_tree_matcher (lshed_data)),
	
	# Create diagnostics for RF
	tar_target(match_diagnostic_plots, 
							make_match_diagnostic_plots(rf_match_data, physician_data), 
							format = "file"
							), 
	
	# Make presentaiton for L2 Meeting
	tar_render(match_slides, "linkage_slides.Rmd")
	
)

