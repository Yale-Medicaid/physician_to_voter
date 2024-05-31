library(glue)
library(arrow)
library(yesno)

df <- read_parquet("data/labelled_training_data//ben.parquet")
n <- nrow(df)

for (i in 504:n) {
	print(glue("Iteration {i} out of {n}"))
	
	print(glue("
							>     name_1:                       {df$full_name.x[i]} 
							>     name_2:                       {df$full_name.y[i]} 
							>     zip_dist:                     {df$zip_dist[i]} 
							>     year_dist:                    {df$year_dist[i]}
							>     Occupation:                   {df$CommercialData_Occupation[i]}
							>     Number of Candidates for NPI: {df$n[i]}
						 "
						 ))
	
	
	df$match[i] <- yesno2("Do These Records Match?")
}

write_parquet(df, "data/labelled_training_data/ben.parquet")
