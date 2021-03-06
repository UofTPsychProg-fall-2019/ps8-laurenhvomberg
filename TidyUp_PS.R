### In this problem set, you will tidy up an IAT dataset 
### The original data is available at https://osf.io/szwuf/, but it comes as an SPSS .sav file
### I've included trimmed down .csv version of 2019's data in this repository for you to work with

# loading libraries  ---------------------------------------------
library(tidyverse)

# reading in IAT data  ---------------------------------------------

# use a tidyverse function to read in the included IAT_2019.csv file 
tbl <- read_csv("IAT.csv")
tbl %>%
  View

# Removing unnecessary rows and columns  ---------------------------------------------
# This data frame only contains 21 of the 454 available variables, but it's still too much

# use tidyverse functions so that only the following variables are included: 'session_id',"genderidentity","raceomb_002","D_biep.White_Good_all","Mn_RT_all_3467",
#       "edu_14","politicalid_7","STATE","att_7","tblacks_0to10","twhites_0to10","labels"

tbl_clean <- select(tbl, session_id, gender, raceomb_002, D_biep.White_Good_all, Mn_RT_all_3467, edu_14, politicalid_7, STATE, att_7, tblacks_0to10, twhites_0to10, labels)

# next, clean up the rows 
# our primary dependent variable is D_biep.White_Good_all, but some subjects
# don't have any data. Remove the rows with missing D_biep.White_Good_all entries 
tbl_clean <- drop_na(tbl, D_biep.White_Good_all)

# Renaming varialbles  ---------------------------------------------

# next rename variables with more intuitive, short labels 
# here are some suggestions (along with variable info)
# id : session_id (subject number)
# gender : genderidentity (gender 1 "Male" 2 "Female" 3 "Trans male/Trans man" 4 "Trans female/Trans woman" 5 "Genderqueer/Gender nonconforming" 6 "A different identity") 
# race : raceomb_002 (race: 1 "American Indian" 2 "East Asian" 3 "South Asian" 4 "Hawaiian Pacifica Islander" 5 "black Africian American" 6 "white" 7 "other" 8 "multiracial")
# bias :D_biep.White_Good_all (overall IAT score)
# rt : Mn_RT_all_3467 (overall reaction time)
# edu : edu_14 (education: 1 "elementary" 2 "junior high" 3 "some high school" 4 "HS grad" 5 "some college" 6 "associate's" 7 "bachelor's" 8 "some grad" 9 "MA" 10 "JD" 11 "MD" 12 "PHD" 13 "other advanced" 14 "MBA")
# pol : politicalid_7 (political identification: 1 "strongly conservative 7 "strongly liberal)
# state : STATE
# att : att_7 (race attitude 1 "strongly prefer AA" 7 "strongly prefer white")
# temp_b : tblacks_0to10 (temperature feelings black 1 "extremely cold" 10 "extremly warm")
# temp_w : twhites_0to10 (temperature feelings black 1 "extremely cold" 10 "extremly warm")

tbl_clean <- rename(tbl,
                    id = session_id, 
                    genderidentity = gender,
                    race = raceomb_002,
                    bias = D_biep.White_Good_all,
                    rt = Mn_RT_all_3467,
                    edu = edu_14,
                    pol = politicalid_7,
                    state = STATE,
                    att = att_7,
                    temp_b = tblacks_0to10,
                    temp_w = twhites_0to10)

#  missing values  ---------------------------------------------  

summary(tbl_clean)
# some of our variables have missing values that aren't properly coded as missing  
# recode missing values in gender and state

tbl_clean$genderidentity <- na_if(tbl_clean$genderidentity, '-1')

tbl_clean$state <- na_if(tbl_clean$state, '-1')

# changing variable types  ---------------------------------------------  
# next, convert id and all variables that are character types to factors
# try to convert all variables at once using tidyverse functions

factorVar <- c('id', 'genderidentity','race', 'bias', 'rt','edu','pol','state','att','temp_b','temp_w')

tbl_clean <- mutate_at(tbl_clean, factorVar, ~factor(.))


# recoding variables  ---------------------------------------------  
# participants were instructed to select all the gender idenities that apply to them
# this results in a lot of combinations!
# this pipeline tabulates the number of participants who endorse different gender identities. 
gender_count <- tbl_clean %>% group_by(genderidentity) %>% tally()  

# sort the output and then use indexing to print the 3 most common response (not inlcuding missing values)
gender_count <- arrange(gender_count, desc(n))

gender_count %>%
  View

# create a new variable that recodes gender to have 4 levels: the 3 most common responses and the others collapsed together
# you can use the key provided on line 31 to understand the levels
# check out recode documentation to see if there's a trick for setting defaults values for unspecified rows
# *note that this excercise in data recoding doesn't reflect the instructors' views on gender identities...
tbl_clean$gender4 <- recode_factor(tbl$gender, `2`="Female", `1`="Male", `5`="Genderqueer") 

# Now take a look at how highest obtained education is coded (key on line 35)
edu_count <- tbl_clean %>% group_by('edu_14') %>% tally()  

#create a new variable that recodes education into: no highscool, some highschool, highschool graduate, some college, postsecondary degree, masters (MA & MBA), advanced degree
#remember that the recode function isn't always the best solution for numeric variables
tbl_clean$edu7 <- recode_factor(tbl$edu_14, `1:8`="no highschool", `9:12`="some highschool", `12`="highschool graduate", `13:17`="some college", `17`="postsecondary degree", `17:19`="masters", `19`="advanced degree")

# mutating variables ---------------------------------------------  
# rewrite the above recoding steps so that they both occur within a single call of the mutate function
tbl_clean <- mutate(tbl_clean, tbl_clean$gender4, tbl_clean$edu7)
  
# filtering and math ---------------------------------------------  

# using filtering, calculate and print the mean bias score for:

# white men
tbl_wm <- mutate(tbl_clean, avg = mean(bias), 1)

# white women
tbl_ww <- mutate(tbl_clean, avg = mean(bias), 2)

# advanced degree holders who are men
tbl_adm <- mutate(tbl_clean, avg = mean(bias), "advanced degree", genderidentity==1)

# high school graduates who are men
tbl_hsm <- mutate(tbl_clean, avg = mean(bias),"highschool graduate", genderidentity==1)




