# bereken_scores.R
library(data.table)
library(stringr)

# input: named list vanuit Wix → flat
bereken_scores <- function(input) {
  
  # 1) list naar data.table
  dt <- as.data.table(as.list(input))
  
  # -------------------------------------------------------------
  # 2) Kolomnamen harmoniseren: E-mail of E.mail → altijd E_mail
  # -------------------------------------------------------------
  names(dt) <- gsub("-", "_", names(dt))
  names(dt) <- gsub("\\.", "_", names(dt))
  
  # nu bestaat er 1 uniforme naam:
  #  Voornaam
  #  E_mail
  
  # -------------------------------------------------------------
  # 3) Scorekolommen identificeren
  # Alle vragen starten met "hoe"
  # Wix maakt lowercase namen → correct
  # -------------------------------------------------------------
  cols <- grep("^hoe", names(dt), ignore.case = TRUE, value = TRUE)
  
  # -------------------------------------------------------------
  # 4) Per vraag score berekenen
  # -------------------------------------------------------------
  for (col in cols) {
    dt[, paste0(col, "_score") := {
      x <- get(col)
      if (is.null(x) || is.na(x) || x == "") {
        0
      } else {
        stringr::str_count(x, ";") + 1
      }
    }]
  }
  
  # -------------------------------------------------------------
  # 5) Verzamel scorekolommen + Voornaam + E_mail
  # -------------------------------------------------------------
  score_cols <- c("Voornaam", "E_mail", grep("_score$", names(dt), value = TRUE))
  dt_scores <- dt[, ..score_cols]
  
  # -------------------------------------------------------------
  # 6) Controle
  # -------------------------------------------------------------
  n_score_cols <- ncol(dt_scores) - 2
  if (n_score_cols != 20) {
    warning("Onverwacht aantal scorekolommen: verwacht 20, kreeg ", n_score_cols)
  }
  
  # -------------------------------------------------------------
  # 7) Percentages berekenen
  # -------------------------------------------------------------
  # Indexen: 3-10 / 11-14 / 15-18 / 19-22
  dt_scores[, Adaptiv_pct      := (rowSums(.SD[, 3:10,   with = FALSE]) / (8 * 4))  * 100]
  dt_scores[, Balance_pct      := (rowSums(.SD[, 11:14,  with = FALSE]) / (4 * 4))  * 100]
  dt_scores[, CitrusBliss_pct  := (rowSums(.SD[, 15:18,  with = FALSE]) / (4 * 4))  * 100]
  dt_scores[, Serenity_pct     := (rowSums(.SD[, 19:22,  with = FALSE]) / (4 * 4))  * 100]
  
  # -------------------------------------------------------------
  # 8) Output als list
  # -------------------------------------------------------------
  out <- as.list(dt_scores[1, .(
    Adaptiv_pct,
    Balance_pct,
    CitrusBliss_pct,
    Serenity_pct
  )])
  
  return(out)
}
