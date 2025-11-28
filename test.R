library(httr)
library(jsonlite)

test_json <- toJSON(list(
  Voornaam = "Heidi",
  E.mail = "test@example.com",
  `Hoe.herkenbaar.zijn.deze.gevoelens.wanneer.je.onder.druk.staat.` = "optie1;optie2",
  `Hoe.ga.jij.om.met.situaties.die.je.niet.kan.controleren.` = "optie1",
  `Hoe.kijk.jij.naar.jezelf.wanneer.je.emotioneel.bent.` = "",
  `Hoe.ga.jij.om.met.innerlijke.onrust.` = "optie1;optie2;optie3",
  `Hoe.makkelijk.kan.jij.luisteren.naar.wat.je.emoties.jou.vertellen.` = "",
  `Hoe.ervaar.jij.stress.die.zich.opstapelt.` = "optie1",
  `Hoe.belangrijk.is.emotionele.veiligheid.voor.jou.` = "",
  `Hoe.herkenbaar.zijn.deze.positieve.verlangens.` = "optie1;optie2",
  `Hoe.aanwezig.voel.je.je.in.het.dagelijks.leven.` = "",
  `Hoe.stabiel.voel.je.je.emotioneel.en.energetisch.` = "",
  `Hoe.ga.je.om.met.verbinding.` = "",
  `Hoe.ga.je.om.met.lange.termijn.doelen.` = "optie1",
  `Hoe.creatief.voel.je.je.momenteel.` = "",
  `Hoe.gemotiveerd.voel.je.je.` = "",
  `Hoeveel.ruimte.is.er.voor.speelsheid.in.je.leven.` = "",
  `Hoe.vrij.voel.jij.je.in.zelfexpressie.` = "",
  `Hoe.gemakkelijk.kan.je.je.geest.tot.rust.brengen.` = "",
  `Hoe.ga.je.om.met.stress.en.overweldiging.` = "",
  `Hoe.moeilijk.is.het.voor.jou.om.echt.te.ontspannen.` = "",
  `Hoe.ervaar.je.verbinding.met.jezelf.en.anderen.` = ""
), auto_unbox = TRUE)

POST("http://127.0.0.1:8000/process", body = test_json, encode = "json")



