library(plumber)
library(jsonlite)
library(data.table)
library(magick)

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
  
  raw <- req$postBody
  
  # ---- 1) Probeer JSON ----
  input <- tryCatch(
    jsonlite::fromJSON(raw),
    error = function(e) NULL
  )
  
  # ---- 2) Als geen JSON → probeer form-data van Wix ----
  if (is.null(input)) {
    input <- tryCatch(
      as.list(parseQueryString(raw)),
      error = function(e) NULL
    )
  }
  
  # ---- 3) Safety fallback ----
  if (is.null(input)) {
    stop("Kon de payload niet lezen. Noch JSON noch form-data.")
  }
  
  # ---- 4) DEBUG LOGGEN ZONDER IETS TE WIJZIGEN ----
  print("----- RAW PAYLOAD ONTVANGEN VAN WIX / JSON ----")
  print(input)
  
  # ---- 5) Verplichte velden (nog niets veranderen aan namen!) ----
  naam  <- input$Voornaam
  email <- input$E.mail   # We laten dit staan zolang we niet weten wat Wix stuurt
  
  if (is.null(naam) || is.null(email)) {
    stop("Voornaam en E.mail zijn verplicht in de payload.")
  }
  
  # ---- 6) Scores berekenen ----
  scores <- bereken_scores(input)
  
  # ---- 7) PNG genereren ----
  png_path <- genereer_png(scores, id = email)
  
  # ---- 8) Publieke URL genereren ----
  png_url <- upload_to_github(png_path)
  
  # ---- 9) Emailtekst genereren ----
  email_text <- genereer_emailtekst(scores, naam)
  
  # ---- 10) JSON response naar Wix ----
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
