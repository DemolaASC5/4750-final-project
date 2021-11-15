# 4750-final-project
This repo contains all commits for the BEE 4750: Environmental Systems Analysis project for Anna Cliche, Cormac Mahoney, and Demola Ogunnaike.  

## Overview of GitHub Commands: 
Before using any of the commands below, make sure that you're in the project directory. 

For Anna, from terminal: 
1. `cd Desktop` 
2. `cd BEE 4750` 
3. `cd 4750-final-project` 

For Cormac, from command prompt or GitBash: 
1. `cd Documents` 
2. `cd BEE4750` 
3. `cd 4750-final-project` 

## Adding Changes (Pushing)
1. `git add .`
2. `git commit -m "message describing change"`
3.  `git push origin "repo name"` 
    - If prompted to enter your credentials, your username is your GitHub username 
    - For password, you need to generate a <a href = "https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token"> personal access token </a> (if you don't already have one). Once creating one, safe the access token where you can easily access it, since you'll need it to push any future changes. 

## Merging Changes from your branch to main repo
1. There should be a notification in GitHub indicating that you recently pushed, but if not navigate to your branch in the repository. 
2. Select compare & pull request or contribute --> Open pull request 
3. You should be able to merge, but if you aren't still create a pull request. 
4. If you were able to merge in the previous step, select merge pull request. If you were unable to merge, either @ Demola in Slack or try to resolve it. 

## Getting Most Up to Date Code (Pulling)
1. git pull origin master
    - If you're running the code for the first time in a while or need changes, I would strongly recommend doing git pull first before working. You'll also have to restart your notebook for your changes to be in full effect.
