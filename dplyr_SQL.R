# dplyr and SQL

library(tidyverse)
library(sqldf)

species_clean <- read.csv("site_by_species.csv")

var_clean <- read.csv("site_by_variables.csv")

head(species_clean)
head(var_clean)

# Start using operations with only 1 file

# Subsetting rows
species <- filter(species_clean, Site < 30)
var <- filter(var_clean, Site < 30)

# SQL Method
# Create a query first: sort of like a statment like a regular expression, where you're determining the datatset, what function/actions you're doing, and the conditions for it, You then apply that query to sqldf()

query = "SELECT Site, Sp1, Sp2, Sp3 FROM species WHERE site < '30'"
sqldf(query)


# Subset columns we use the dplyr select() function, and it can use either column # or name

edit_species <- species %>% 
  select(Site, Sp1, Sp2, Sp3)

edit_species2 <- species %>% 
  select(1:4) # Using commas is the same as 1:4

# Query the entire table in SQL

query = "SELECT * FROM species"

a = sqldf(query)
sqldf(query)

# reordering columns
query = "SELECT Sp1, Sp2, Sp3, Site FROM species"
sqldf(query)


# Pivoting longer and wider
# pivot_longer (gather) lengthens data, decrease nujmber of columns, and decreases number of rows

species_long <- pivot_longer(edit_species, cols = c(Sp1,Sp2,Sp3), names_to = "ID")
head(species_long)

species_wide <- pivot_wider(species_long, names_from = ID)
head(species_wide)


# SQL Method
# Aggregating to give counts of object types

query = "
SELECT SUM(Sp1+Sp2+Sp3)
FROM species_wide
GROUP BY SITE
"
sqldf(query)

#the same as mutate function
query = "
SELECT SUM(Sp1+Sp2+Sp3) AS OCCURENCE 
FROM species_wide
GROUP BY SITE
"
sqldf(query)


# Mutate in SQL - create a new column
query = "
ALTER TABLE species_wide
ADD new_column VARCHAR
"
sqldf(query)


#2 File Operations
# Joins: gathering data into usable formats. People will often store data into different variables/types of data into different files. As opposed to just binding things, we often new to join them together

# Left/Right?Union  joins
# Start with clean data sets: reset species and var variables, and filter the to a smaller size

edit_species <- species_clean %>% 
  filter( Site < 30) %>% 
  select(Site, Sp1, Sp2, Sp3, Longitude.x., Latitude.y.)

edit_var <- var_clean %>% 
  filter(Site < 30) %>% 
  select(Site, Longitude.x., Latitude.y.,
         BIO1_Annual_mean_temperature,
         BIO12_Annual_precipitation)

# left join - stitching the matching rows of file B to file A
left <- left_join(edit_species, edit_var, by = "Site")

# right join - sticthing the matching rows of file A to B. The only difference is what is lost when you match them together
right <- right_join(edit_species, edit_var, by = "Site")

# Inner_join - retains rows that match between both A and B. It loses a lot of info if the two files don'tmatch up well

inner <- inner_join(edit_species, edit_var, by = "Site")

# Full_join - the opposite of an inner join, it's going to retain all values, all rows, so instead of losing many rows, you just have a bunch of NA's whereever there is missing data

full <- full_join(edit_species, edit_var, by = "Site")


# SQL Method

query = "
SELECT BIO1_Annual_mean_temperature,
BIO12_Annual_precipitation FROM edit_var
LEFT JOIN edit_species ON edit_var.Site = edit_species.Site"
x <- sqldf(query)
