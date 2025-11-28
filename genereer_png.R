# genereer_png.R
library(magick)

# Basiskleuren voor de 4 hoeken (zoals in jouw code)
mm_colors <- c(
  top_left     = "#6a4c9c",  # Serenity
  top_right    = "#fa9c1a",  # Citrus Bliss
  bottom_left  = "#4d7e6f",  # Balance
  bottom_right = "#2685cd"   # Adaptiv
)

# Helper: tekst in hoek zetten
add_text_corner <- function(image, text, gravity, color, offset = 20) {
  image_annotate(
    image,
    text,
    size   = 80,
    color  = color,
    weight = 700,
    gravity = gravity,
    location = paste0("+", offset, "+", offset)
  )
}

# genereer_png:
# - scores: list met Adaptiv_pct, Balance_pct, CitrusBliss_pct, Serenity_pct
# - id: character om bestandsnaam uniek te maken (bijv. e-mail of Voornaam)
# return: lokaal pad naar PNG-file
genereer_png <- function(scores, id, template_path = "MoodCollection_socialMedia.png") {
  if (!file.exists(template_path)) {
    stop("Template afbeelding niet gevonden: ", template_path)
  }
  
  img <- image_read(template_path)
  
  # Percentages afronden (optioneel)
  serenity_txt    <- paste0(round(scores$Serenity_pct, 2), "%")
  citrus_txt      <- paste0(round(scores$CitrusBliss_pct, 2), "%")
  balance_txt     <- paste0(round(scores$Balance_pct, 2), "%")
  adaptiv_txt     <- paste0(round(scores$Adaptiv_pct, 2), "%")
  
  # Tekst toevoegen
  img <- add_text_corner(img, serenity_txt, gravity = "northwest", color = mm_colors["top_left"])
  img <- add_text_corner(img, citrus_txt,   gravity = "northeast", color = mm_colors["top_right"])
  img <- add_text_corner(img, balance_txt,  gravity = "southwest", color = mm_colors["bottom_left"])
  img <- add_text_corner(img, adaptiv_txt,  gravity = "southeast", color = mm_colors["bottom_right"])
  
  # Bestandsnaam veilig maken
  safe_id <- gsub("[^A-Za-z0-9]", "_", id)
  out_path <- paste0("MMprofiel_", safe_id, ".png")
  
  image_write(img, path = out_path, format = "png")
  
  return(out_path)
}
