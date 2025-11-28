# genereer_emailtekst.R

genereer_emailtekst <- function(scores, naam) {
  # scores: list met Adaptiv_pct, Balance_pct, CitrusBliss_pct, Serenity_pct
  
  # 1. Welke blend(s) scoren het hoogst?
  vals  <- unlist(scores)
  names(vals) <- names(scores)
  
  max_val <- max(vals)
  top_blends <- names(vals)[vals == max_val]
  
  # Kleine helper om blendnamen mooi te tonen
  nice_name <- function(blend) {
    switch(
      blend,
      "Adaptiv_pct"     = "Adaptiv",
      "Balance_pct"     = "Balance",
      "CitrusBliss_pct" = "Citrus Bliss",
      "Serenity_pct"    = "Serenity",
      blend
    )
  }
  
  top_nice <- vapply(top_blends, nice_name, character(1))
  
  # 2. Tekst opbouwen
  intro <- paste0("Lieve ", naam, ",\n\n",
                  "Dankjewel om de mood management vragenlijst in te vullen.\n",
                  "Op basis van jouw antwoorden ontstaat een persoonlijk profiel van hoe jij emotioneel ondersteund kan worden op dit moment.\n\n")
  
  # 3. Cases: 1 topper, 2 toppers, of alles redelijk gelijk
  body <- ""
  
  if (length(top_blends) == 1) {
    b <- top_blends[1]
    
    if (b == "Serenity_pct") {
      body <- paste0(
        "In jouw profiel komt vooral **Serenity** naar voren als hoogste score. ",
        "Dat wijst erop dat je momenteel vooral behoefte hebt aan rust, verzachting en mentale ontspanning. ",
        "Serenity ondersteunt je wanneer je hoofd druk is, wanneer je spanning wil loslaten en wanneer je zenuwstelsel om ontprikkeling vraagt.\n\n"
      )
    } else if (b == "CitrusBliss_pct") {
      body <- paste0(
        "In jouw profiel komt vooral **Citrus Bliss** naar voren als hoogste score. ",
        "Dit wijst op een behoefte aan lichtheid, plezier, motivatie en een zachte emotionele uplift. ",
        "Citrus Bliss helpt wanneer je wat meer speelsheid, energie en optimisme wil voelen in je dagelijks leven.\n\n"
      )
    } else if (b == "Balance_pct") {
      body <- paste0(
        "In jouw profiel staat **Balance** het hoogst. ",
        "Dat vertelt dat je systeem vooral baat heeft bij gronding, stabiliteit en terugkeren naar jezelf. ",
        "Balance helpt je om uit je hoofd te zakken en je energie te verankeren, zeker wanneer er veel beweegt in je omgeving.\n\n"
      )
    } else if (b == "Adaptiv_pct") {
      body <- paste0(
        "Bij jou staat **Adaptiv** het hoogst. ",
        "Dit wijst op een behoefte aan mentale flexibiliteit, stressregulatie en meer ruimte in je hoofd. ",
        "Adaptiv ondersteunt je wanneer er veel prikkels zijn of wanneer je makkelijker wil schakelen tussen verschillende rollen en verantwoordelijkheden.\n\n"
      )
    }
  } else if (length(top_blends) == 2) {
    # Twee toppers
    combo <- paste(top_nice, collapse = " en ")
    body <- paste0(
      "In jouw profiel springen **", combo, "** er samen uit als hoogste scores. ",
      "Dat betekent dat beide blends op dit moment mooi aansluiten bij jouw emotionele noden. ",
      "Je kan intuïtief kiezen met welke je wil starten, of ze op verschillende momenten van de dag inzetten.\n\n"
    )
  } else {
    # Veel gelijk / vlak profiel
    body <- paste0(
      "Jouw scores liggen vrij dicht bij elkaar, zonder één uitgesproken winnaar. ",
      "Dat betekent dat verschillende soorten ondersteuning op dit moment waardevol kunnen zijn: een mix van rust, gronding, lichtheid en mentale ruimte. ",
      "In zulke gevallen is je neus vaak de beste gids: ruik aan de verschillende blends en voel welke het sterkst met jou resoneert.\n\n"
    )
  }
  
  # 4. Algemene uitleg over hoe scores te lezen
  uitleg <- paste0(
    "Hoe hoger de score van een blend, hoe dichter die aansluit bij wat jij emotioneel nodig hebt op dit moment. ",
    "Een lagere score wil niet zeggen dat een olie 'niet werkt', maar wel dat jouw systeem er momenteel minder nadrukkelijk om vraagt. ",
    "Gebruik je profiel gerust als richtingaanwijzer, en laat je intuïtie de uiteindelijke keuze maken.\n\n"
  )
  
  afsluit <- paste0(
    "Je persoonlijke score-overzicht krijg je in de bijgevoegde afbeelding te zien.\n\n",
    "Laat me zeker weten of dit profiel herkenbaar voelt voor jou. ",
    "Met jullie ervaring in de oliën is jullie feedback ontzettend waardevol om de vragenlijst verder te verfijnen en nog accurater te maken.\n\n",
    "Liefs,\nHeidi\n"
  )
  
  # 5. Samenvoegen (zonder **, dat is voor markdown; voor platte tekst kan je ze weglaten of vervangen)
  full <- paste0(intro, body, uitleg, afsluit)
  return(full)
}
