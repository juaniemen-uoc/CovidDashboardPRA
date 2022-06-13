## Acceso de ACLED
raw_data <-
  read_excel('ACLEDRusiaUcrania.xlsx')

# There are some missing iso3 values
raw_data$iso3[is.na(raw_data$iso3) & raw_data$country=="Russia"] <- "RUS"
raw_data$iso3[is.na(raw_data$iso3) & raw_data$country == "Ukraine"] <- "UKR"

Battles
Explosions/Remote violence
Protests
Riots
Strategic developments
Violence against civilians