# bereken_scores.R
library(data.table)
library(stringr)

# input: named list met velden zoals uit Wix (Voornaam, E.mail, Hoe... )
# output: named list met percentages (Adaptiv_pct, Balance_pct, CitrusBliss_pct, Serenity_pct)
bereken_scores <- function(input) {
  # 1 rij data.table maken van de binnenkomende list
  dt <- as.data.table(as.list(input))
  
  # Kolommen met de vragen (zoals in jouw code)
  cols <- grep("^Hoe", names(dt), value = TRUE)
  
  # Per vraag een _score kolom toevoegen
  for (col in cols) {
    dt[, paste0(col, "_score") := {
      x <- get(col)
      semis <- stringr::str_count(x, ";")      # aantal ';'
      score <- ifelse(x == "" | is.na(x),
                      0,                       # lege string of NA → 0 punten
                      semis + 1)               # anders: aantal ";" + 1
      score
    }]
  }
  
  # Enkel de scorekolommen + Voornaam + E.mail
  score_cols <- c("Voornaam", "E.mail", grep("_score$", names(dt), value = TRUE))
  dt_scores <- dt[, ..score_cols]
  
  # Als er lege voornamen zijn, die skippen (zou hier niet mogen voorkomen)
  dt_scores <- dt_scores[Voornaam != ""]
  
  # Controle op aantal score-vragen (verwacht: 20)
  n_score_cols <- ncol(dt_scores) - 2
  if (n_score_cols != 20) {
    warning("Onverwacht aantal scorekolommen: verwacht 20, kreeg ", n_score_cols,
            ". Controleer de mapping van vragen → blends.")
  }
  
  # Percentages berekenen (exact zoals in jouw code)
  # Kolomindexen in dt_scores:
  # 1 = Voornaam, 2 = E.mail, 3-10 = Adaptiv, 11-14 = Balance, 15-18 = CitrusBliss, 19-22 = Serenity
  dt_scores[, Adaptiv_pct      := (rowSums(.SD[, 3:10,   with = FALSE]) / (8 * 4))  * 100]
  dt_scores[, Balance_pct      := (rowSums(.SD[, 11:14,  with = FALSE]) / (4 * 4))  * 100]
  dt_scores[, CitrusBliss_pct  := (rowSums(.SD[, 15:18,  with = FALSE]) / (4 * 4))  * 100]
  dt_scores[, Serenity_pct     := (rowSums(.SD[, 19:22,  with = FALSE]) / (4 * 4))  * 100]
  
  # 1 rij → list met percentages
  out <- as.list(dt_scores[1, .(Adaptiv_pct, Balance_pct, CitrusBliss_pct, Serenity_pct)])
  return(out)
}
