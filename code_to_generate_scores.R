data <- read.csv("Mood Management kit.csv")
data[is.na(data)] <- 0

adaptive <- data$Ik.wil.graag.motivatie.en.een.mentale.boost.om.de.dag.te.starten+ 
  data$Het.gevoel.dat.de.zaken.niet.lopen.zoals.gepland + 
  data$In.de.buitenlucht..wandelen..frisse.wind..terug.overzicht.krijgen + 
  data$optimale.mentale.controle.en.focus +
  data$Ik.heb.tools.nodig.om.overzicht.te.kunnen.bewaren +
  data$Mentale.helderheid.en.focus + 
  data$Beter.kunnen.omgaan.met.stress.en.meer.zelfzekerheid +
  data$Ik.wil.meer.grip.op.mijn.gedachten.en.emoties

balance <- data$Ik.zoek.liever.rust.en.stabiliteit.bij.het.opstaan + 
  data$Chaotische.situaties.waarbij.ik.mijn.mezelf.en.mijn.gronding.verlies +
  data$yoga..meditatie.of.acitiviteiten.die.je.terug.in.balans.brengen +
  data$Eerder.nuchter..stabiel.en.evenwichtig +
  data$Ik.probeer.te.relativeren.en.evenwicht.te.behouden +
  data$stabiliteit.en.innerlijke.aarding +
  data$Meer.stabiliteit.en.innerlijke.rust + 
  data$Ik.blijf.graag.nuchter..kalm.en.sta.gegrond.en.in.mijn.kracht

citrusbliss <- data$Ik.start.de.dag.het.liefst.licht..vrolijk.en.optimistisch +
  data$Negativiteit.of.zware..depressieve.energie.rondom.mij +
  data$Plezier.maken..lachen..sociale.energie..dingendoen.die.als..licht.aanvoelen +
  data$Levenslustig..optimistisch..ziet.elke.dag.als.een.cadeau +
  data$Ik.zoek.positieve.prikkels.die.mijn.energie.optillen +
  data$Optimisme..speelsheid.en.lichtheid +
  data$Meer.plezier..spontaniteit.en.positiviteit +
  data$Ik.ben.de.optimist.van.de.groep.en.dans.het.liefst.door.het.leven

serenity <- data$Ik.heb.graag.tijd.en.zachtheid.om.rustig.opgang.te.komen +
  data$Drukte..veel.lawaai.en.of.overprikkeling +
  data$Me.time..rust..een.boek..warm.cocoonmomenten +
  data$Rustig..introvert..houdt.van.cozy.en.vertragen +
  data$Kalmte..diepe.ontspanning.en.zachtheid +
  data$Rust..slaap.en.ontspanning +
  data$Ik.voel.me.het.best.in.een.rustige.kalme.omgeving

adaptive[1]/40*100
balance[1]/40*100
citrusbliss[1]/40*100
serenity[1]/40*100
library(data.table)

dt <- read.csv("MMform.csv")
dt <-data.table(dt)
cols <- grep("^Hoe", names(dt), value = TRUE)
for (col in cols) {
  # tel aantal ';' per cel
  dt[, paste0(col, "_score") :=
       {
         x <- get(col)
         semis <- stringr::str_count(x, ";")  # aantal ;
         
         # score-regels toepassen
         score <- ifelse(x == "" | is.na(x),
                         0,           # lege string of NA → 0 punten
                         semis + 1)   # anders: aantal ";" + 1
         score
       }
  ]
}

score_cols <- c("Voornaam", "E.mail",grep("_score$", names(dt), value = TRUE))
dt_scores <- dt[, ..score_cols]
dt_scores <- dt_scores[Voornaam!=""]
# Nieuwe score‐kolommen berekenen
dt_scores[, Adaptiv_pct      := (rowSums(.SD[, 3:10,     with=FALSE]) / (8*4))  * 100]
dt_scores[, Balance_pct      := (rowSums(.SD[, 11:14,    with=FALSE]) / (4*4))  * 100]
dt_scores[, CitrusBliss_pct  := (rowSums(.SD[, 15:18,   with=FALSE]) / (4*4))  * 100]
dt_scores[, Serenity_pct     := (rowSums(.SD[, 19:22,   with=FALSE]) / (4*4))  * 100]
dt_scores[,c("Voornaam", "E.mail","Adaptiv_pct","Balance_pct" ,"CitrusBliss_pct","Serenity_pct")]

library(magick)

# Bestand inlezen
colors <- c(
  top_left = "#6a4c9c",#"purple",    # Serenity
  top_right = "#fa9c1a", #"orange",   # Citrus Bliss
  bottom_left = "#4d7e6f",#"green",  # Balance
  bottom_right = "#2685cd"#"blue"   # Adaptiv
)
# Functie om tekst op een hoek te zetten
add_text_corner <- function(image, text, gravity, color, offset = 20){
  image_annotate(image, text, size = 80, color = color, weight = 700,
                 gravity = gravity, location = paste0("+", offset, "+", offset))
}


for(i in 1:nrow(dt_scores)) {
  img <- image_read("MoodCollection_socialMedia.png")  
  # Percentages die je wilt tonen
  percentages <- c(
    top_left = paste0(dt_scores$Serenity_pct[i], "%"),
    top_right = paste0(dt_scores$CitrusBliss_pct[i], "%"),
    bottom_left = paste0(dt_scores$Balance_pct[i], "%"),
    bottom_right = paste0(dt_scores$Adaptiv_pct[i], "%")
  )
  # Tekst toevoegen in vier hoeken
  img <- add_text_corner(img, percentages["top_left"], gravity = "northwest", color = colors["top_left"])
  img <- add_text_corner(img, percentages["top_right"], gravity = "northeast", color = colors["top_right"])
  img <- add_text_corner(img, percentages["bottom_left"], gravity = "southwest", color = colors["bottom_left"])
  img <- add_text_corner(img, percentages["bottom_right"], gravity = "southeast", color = colors["bottom_right"])
  
  # Opslaan
  image_write(img, path = paste0("MMprofiel",dt_scores$E.mail[i],".png"), format = "png")
}

