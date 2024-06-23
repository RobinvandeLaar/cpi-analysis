# Installeren van pakketten (indien nog niet geïnstalleerd)
install.packages("httr")
install.packages("jsonlite")
install.packages("dplyr")
install.packages("ggplot2")
install.packages("lubridate")
install.packages("DBI")
install.packages("RSQLite")
install.packages("base64enc")

# Laden van pakketten
library(httr)
library(jsonlite)
library(dplyr)
library(ggplot2)
library(lubridate)
library(DBI)
library(RSQLite)
library(base64enc)

# Definieer de basis URL
base_url <- "https://opendata.cbs.nl/ODataApi/OData/83131NED/TypedDataSet"

# Definieer de productcodes voor rijst en varkensvlees
product_codes <- c("CPI011110", "CPI011220")

# Functie om data op te halen voor een specifieke productcode
get_product_data <- function(product_code) {
  url <- paste0(base_url, "?$filter=Bestedingscategorieen+eq+'", product_code, "'")
  response <- GET(url)
  print(url)
  if (response$status_code == 200) {
    data <- fromJSON(content(response, "text"))$value
    return(data)
  } else {
    stop("Failed to fetch data for product code: ", product_code)
  }
}

# Ophalen van data voor rijst en varkensvlees
data_list <- lapply(product_codes, get_product_data)

# Converteer naar data frame
data_df <- bind_rows(data_list)


# Functie om kwartaalmutaties te berekenen voor een specifieke periode
calculate_quarterly_changes <- function(start_period, end_period) {
  
  # Transformeer Perioden naar Period en filter/selecteer relevante data
  data <- data_df %>%
    mutate(Period = ymd(paste0(substr(Perioden, 1, 4), substr(Perioden, 7, 8), "01")),
           CPI_1 = as.numeric(CPI_1)) %>%
    filter(!is.na(Period) & !is.na(CPI_1)) %>%
    filter(Period >= ymd(paste0(start_period, "01")) - months(3), Period <= ymd(paste0(end_period, "01"))) %>%
    select(Period, Bestedingscategorieen, CPI_1)
  
  # Print de eerste paar rijen van de data voor structuurinspectie
  print(head(data))
  
  # Rangschik data op Period
  data <- data %>%
    arrange(Period)
  
  # Bereken kwartaalgemiddelden van CPI_1
  data <- data %>%
    mutate(Year = year(Period),
           Quarter = quarter(Period)) %>%
    group_by(Year, Quarter, Bestedingscategorieen) %>%
    summarize(Avg_CPI = mean(CPI_1, na.rm = TRUE)) %>%
    arrange(Bestedingscategorieen, Year, Quarter) %>%
    ungroup() %>%
    group_by(Bestedingscategorieen) %>% # Groepeer opnieuw alleen per bestedingscategorie
    mutate(Quarterly_Change = (Avg_CPI - lag(Avg_CPI)) / lag(Avg_CPI) * 100)
  
  # Retourneer de resultaten
  return(data)
}

# Voorbeeldgebruik van de functie: bereken kwartaalmutaties tussen een start- en eindperiode
result <- calculate_quarterly_changes("202201", "202403")

# Maak een tijdelijke directory aan voor de grafieken
temp_dir <- tempdir()

# Orden de kwartalen correct en verwijder het allereerste element in YearQuarter (valt buiten verslagperiode)
result <- result %>%
  mutate(YearQuarter = factor(interaction(Year, Quarter), levels = unique(interaction(Year, Quarter)))) %>%
  filter(row_number() > 1)

# Gemiddelde CPI per kwartaal plotten
p1 <- ggplot(result, aes(x = YearQuarter, y = Avg_CPI, color = Bestedingscategorieen, group = Bestedingscategorieen)) +
  geom_line() +
  geom_point() +
  labs(title = "Gemiddelde CPI per kwartaal",
       x = "Kwartaal",
       y = "Gemiddelde CPI") +
  theme_minimal()

print(p1)

# Kwartaalmutaties plotten
p2 <- ggplot(result, aes(x = YearQuarter, y = Quarterly_Change, color = Bestedingscategorieen, group = Bestedingscategorieen)) +
  geom_line() +
  geom_point() +
  labs(title = "Kwartaalmutaties",
       x = "Kwartaal",
       y = "Mutatie (%)") +
  theme_minimal()

print(p2)

# Maak een tijdelijke afbeelding
tempfile_name_1 <- tempfile(fileext = ".png")
ggsave(tempfile_name_1, plot = p1)
tempfile_name_2 <- tempfile(fileext = ".png")
ggsave(tempfile_name_2, plot = p2)

# Lees de tijdelijke afbeelding in als binair object en codeer als base64
image_data_1 <- readBin(tempfile_name_1, "raw", file.info(tempfile_name_1)$size)
encoded_image_1 <- base64encode(image_data_1)
image_data_2 <- readBin(tempfile_name_2, "raw", file.info(tempfile_name_2)$size)
encoded_image_2 <- base64encode(image_data_2)

# Verbind met de database
con <- dbConnect(RSQLite::SQLite(), ":memory:")

# Maak een voorbeeld tabel aan voor het opslaan van grafieken
dbExecute(con, "CREATE TABLE graphs (name TEXT, image BLOB)")

# Sla de grafiek op in de database
dbExecute(con, "INSERT INTO graphs (name, image) VALUES ('example_plot_1', ?)", list(encoded_image_1))
dbExecute(con, "INSERT INTO graphs (name, image) VALUES ('example_plot_2', ?)", list(encoded_image_2))

# Controleer of de grafiek succesvol is opgeslagen
result <- dbGetQuery(con, "SELECT name, LENGTH(image) AS size FROM graphs")
print(result)

# Verwijder de tijdelijke afbeelding
file.remove(tempfile_name_1)
file.remove(tempfile_name_2)

# Sluit de verbinding met de database
dbDisconnect(con)
