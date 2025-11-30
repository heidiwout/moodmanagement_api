# plumber.R
library(plumber)
library(jsonlite)
library(data.table)
library(stringr)

source("bereken_scores.R")
source("genereer_png.R")
source("genereer_emailtekst.R")
source("upload_to_github.R")


#* Health check
#* @get /health
function() {
  list(status = "ok", message = "Mood Management API draait")
}


#* Verwerk 1 formulierinzending vanuit Wix
#* @post /process
function(req) {
  
  raw <- req$postBody
  
  # -----------------------------------
  # 1) Probeer JSON decoderen
  # -----------------------------------
  input <- tryCatch(
    jsonlite::fromJSON(raw),
    error = function(e) NULL
  )
  
  if (is.null(input)) {
    stop("Kon de payload niet als JSON lezen.")
  }
  
  print("===== RAW JSON VAN WIX =====")
  print(input)
  
  # -----------------------------------
  # 2) Extractie van Wix-form submission
  # -----------------------------------
  # Wix structuur:
  #   input$data$submissions$label
  #   input$data$submissions$value
  # + voornaam & email dubbele keer aanwezig
  
  if (!"data" %in% names(input)) {
    stop("Wix JSON bevat geen 'data' veld.")
  }
  
  d <- input$data
  
  # -----------------------------------
  # 3) Submissions flattenen naar named list
  # -----------------------------------
  flat <- list()
  
  # Voornaam & email apart (zekerheid)
  if (!is.null(d$submissions)) {
    subs <- d$submissions
    if (all(c("label","value") %in% names(subs))) {
      for (i in seq_len(nrow(subs))) {
        label <- subs$label[i]
        value <- subs$value[i]
        if (label != "" && !is.null(value)) {
          flat[[label]] <- value
        }
      }
    }
  }
  
  # # Extra Wix velden (field:xyz)
  # wix_fields <- grep("^field:", names(d), value = TRUE)
  # for (f in wix_fields) {
  #   clean_name <- sub("^field:", "", f)
  #   flat[[clean_name]] <- d[[f]]
  # }
  # 
  # Tevens expliciete voornaam & e-mail
  if (!is.null(d$`field:voornaam_24fb`)) {
    flat[["Voornaam"]] <- d$`field:voornaam_24fb`
  }
  if (!is.null(d$`field:e_mail_b046`)) {
    flat[["E-mail"]] <- d$`field:e_mail_b046`
  }

  print("===== FLAT INPUT =====")
  print(flat)
  
  # -----------------------------------
  # 4) Controle verplichte velden
  # -----------------------------------
  naam  <- flat[["Voornaam"]]
  email <- flat[["E-mail"]]
  
  if (is.null(naam) || is.null(email) || naam == "" || email == "") {
    stop("Voornaam en E-mail moeten aanwezig zijn in de Wix payload.")
  }
  
  # -----------------------------------
  # 5) Scores berekenen
  # -----------------------------------
  scores <- bereken_scores(flat)
  
  # -----------------------------------
  # 6) PNG genereren
  # -----------------------------------
  png_path <- genereer_png(scores, id = email)
  
  # -----------------------------------
  # 7) Publieke URL voor de PNG
  # -----------------------------------
  png_url <- upload_to_github(png_path)
  
  # -----------------------------------
  # 8) Emailtekst genereren
  # -----------------------------------
  email_text <- genereer_emailtekst(scores, naam)
  
  # -----------------------------------
  # 9) Output terug naar Wix automation
  # -----------------------------------
  list(
    Voornaam        = jsonlite::unbox(naam),
    E_mail          = jsonlite::unbox(email),
    email_text      = jsonlite::unbox(email_text),
    png_url         = jsonlite::unbox(png_url),
    Adaptiv_pct     = jsonlite::unbox(scores$Adaptiv_pct),
    Balance_pct     = jsonlite::unbox(scores$Balance_pct),
    CitrusBliss_pct = jsonlite::unbox(scores$CitrusBliss_pct),
    Serenity_pct    = jsonlite::unbox(scores$Serenity_pct)
  )
  
}
