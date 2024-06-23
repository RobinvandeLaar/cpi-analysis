# Casus 1: Analyse van Kwartaalmutaties van Consumentenprijzen in R

Dit project demonstreert een proces in R voor het analyseren van kwartaalmutaties van consumentenprijzen van twee interessante producten, gebaseerd op gegevens verkregen via het CBS StatLine.

## Tooling en Vereisten

Voor dit project worden de volgende tools en R-pakketten gebruikt:

- **R**: Programmeertaal voor statistische analyses.
- **RStudio**: Optionele geïntegreerde ontwikkelomgeving (IDE) voor R.
- **R-pakketten**: 
  - `httr`: Voor HTTP-verbindingen en API-aanroepen.
  - `jsonlite`: Voor het verwerken van JSON-gegevens.
  - `dplyr`: Voor gegevensmanipulatie en -transformatie.
  - `lubridate`: Voor werken met datums.
  - `ggplot2`: Voor het maken van grafieken.
  - `DBI`: Voor Database Interface (algemene interface voor interactie met databases).
  - `RSQLite`: Voor SQLite databasebeheer.
  - `base64enc`: Voor het omzetten van afbeeldingsgegevens naar base64-formaat.

Je kunt deze pakketten installeren met behulp van `install.packages("pakketnaam")` in R.

## Proces

### 1. Data ophalen vanuit CBS StatLine

- De data voor twee producten worden opgehaald vanuit CBS StatLine via hun OData API.

### 2. Berekenen van Kwartaalmutaties

- Een functie wordt gebruikt om de kwartaalmutatie te berekenen op basis van maandelijkse gegevens.

### 3. Maken van Grafieken en Opslaan in een Lokale Database

- Grafieken van de gemiddelde consumentenprijs per kwartaal en de bijbehorende kwartaalmutaties worden gemaakt met behulp van ggplot2.
- De gegenereerde grafieken worden opgeslagen als afbeeldingsbestanden in een SQLite database.

### 4. GitHub Repository

- De volledige R-code en dit README-bestand worden opgeslagen in een openbare GitHub repository voor toegankelijkheid en versiebeheer.

## Gebruik

Volg deze stappen om het project uit te voeren:

1. Clone deze repository naar je lokale machine:

   ```sh
   git clone https://github.com/RobinvandeLaar/cpi-analysis.git
   cd cpi-analysis

2. Installeer de benodigde R-pakketten zoals vermeld in de sectie "Tooling en Vereisten".
3. Voer het R-script uit (cpi_analysis.R) in R of RStudio:
  ```r
    Rscript cpi_analysis.R

4. Bekijk de resultaten in de gegenereerde grafieken en controleer of deze correct zijn opgeslagen in de SQLite database.

