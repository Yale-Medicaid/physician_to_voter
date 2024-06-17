# Instructions for Replicating

## Step 1: Clone the repository

Use the git command line to clone the physician to voter repository.  This
assumes that you have your ssh keys setup. If you don't, check out the
instructions
[here](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent).

```
git clone git@github.com:Yale-Medicaid/physician_to_voter.git
cd physician_to_voter
```

## Step 2: Initialize the Python virtual environment and install DVC

This step is needed to ensure that you have access to [Data Version
Control](https://dvc.org/), which is used to load the raw voter files from a
cache on the server.

!!! Tip inline end

    If you are on linux or MacOS, you should replace line 2 with `source venv/bin/activate`


```
python -m venv venv
source venv/Scripts/activate
pip install -r requirements.txt
```


## Step 3: Retrieve cached versions of the voter file using DVC

This step is easy! Simply run:

```
dvc pull
```

This pulls copies of the voter files and physician files from a secure backup
folder. This code will only work on the server.

## Step 4: Run the pipeline

The R-dependencies are automatically managed by [renv](https://rstudio.github.io/renv/articles/renv.html), which will install any missing packages on startup. This means that you can start the code pipeline by simply running the following lines in an R session running inside the root directory.

```r
> targets::tar_make()
```

This will start the process to link the physician and voter files. The linked dataset can be accessed by running the following command in R:

```r
> targets::tar_read(rf_match_data)
```
