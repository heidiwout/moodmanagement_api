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
  # 3) Scorekolommen identificeren (alle vragen die ik nodig heb)
  # Alle vragen starten met "hoe"
  # Wix maakt lowercase namen → correct
  # -------------------------------------------------------------
  #cols <- grep("^Hoe", names(dt), ignore.case = TRUE, value = TRUE)
  cols <- c(
    "Hoe herkenbaar zijn deze gevoelens wanneer je onder druk staat?",
    "Hoe ga jij om met situaties die je niet kan controleren?",
    "Hoe kijk jij naar jezelf wanneer je emotioneel bent?",
    "Hoe ga jij om met innerlijke onrust?",
    "Hoe makkelijk kan jij luisteren naar wat je emoties jou vertellen?",
    "Hoe ervaar jij stress die zich opstapelt?",
    "Hoe belangrijk is emotionele veiligheid voor jou?",
    "Hoe herkenbaar zijn deze positieve verlangens?",
    "Hoe aanwezig voel je je in het dagelijks leven?",
    "Hoe stabiel voel je je emotioneel en energetisch?",
    "Hoe ga je om met verbinding?",
    "Hoe ga je om met lange-termijn doelen?",
    "Hoe creatief voel je je momenteel?",
    "Hoe gemotiveerd voel je je?",
    "Hoeveel ruimte is er voor speelsheid in je leven?",
    "Hoe vrij voel jij je in zelfexpressie?",
    "Hoe gemakkelijk kan je je geest tot rust brengen?",
    "Hoe ga je om met stress en overweldiging?",
    "Hoe moeilijk is het voor jou om echt te ontspannen?",
    "Hoe ervaar je verbinding met jezelf en anderen?"
  )
  # -------------------------------------------------------------
  # 4) Per vraag scorekolom toevoegen (score = aantal antwoorden)
  # -------------------------------------------------------------
  for (col in cols) {
    if (!col %in% names(dt)) {
      dt[[col]] <- ""   # ontbrekende vraag → lege string → score 0
    }
    dt[[paste0(col, "_score")]] <- ifelse(
      dt[[col]] == "" | is.na(dt[[col]]),
      0,
      stringr::str_count(dt[[col]], ",") + 1
    )
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
