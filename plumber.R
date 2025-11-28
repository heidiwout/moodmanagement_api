library(plumber)
library(jsonlite)
library(data.table)
library(magick)

# plumber.R
library(plumber)
library(jsonlite)

source("bereken_scores.R")
source("genereer_png.R")
source("genereer_emailtekst.R")
source("upload_to_github.R")

#* Health check
#* @get /health
function() {
  list(status = "ok", message = "Mood Management API draait")
}

#* Verwerk 1 formulierinzending
#* @post /process
function(req) {
  # JSON-body uitlezen
  input <- fromJSON(req$postBody)
  
  # We verwachten minstens deze velden:
  # - Voornaam
  # - E.mail
  # - alle "Hoe..."-kolommen zoals in jouw CSV
  
  naam  <- input$Voornaam
  email <- input$E.mail
  
  if (is.null(naam) || is.null(email)) {
    stop("Voornaam en E.mail zijn verplicht in de payload.")
  }
  
  # Scores berekenen (list met pct's)
  scores <- bereken_scores(input)
  
  # PNG genereren
  png_path <- genereer_png(scores, id = email)
  
  # URL bepalen voor de PNG (moet publiek gehost worden)
  png_url <- upload_to_github(png_path)
  
  # Emailtekst genereren (condities op basis van scores)
  email_text <- genereer_emailtekst(scores, naam)
  
  # Output naar Wix (JSON)
  list(
    Voornaam        = naam,
    E_mail          = email,
    email_text      = email_text,
    png_url         = png_url,
    Adaptiv_pct     = scores$Adaptiv_pct,
    Balance_pct     = scores$Balance_pct,
    CitrusBliss_pct = scores$CitrusBliss_pct,
    Serenity_pct    = scores$Serenity_pct
  )
}
