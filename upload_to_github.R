# upload_to_github.R

# png_path: lokaal bestandspad
# public_base_url: bv. "https://jouwgithubnaam.github.io/moodmanagement_profiles"
# return: volledige URL naar de afbeelding
upload_to_github <- function(png_path,
                             public_base_url = Sys.getenv("MM_PUBLIC_BASE_URL")) {
  if (is.null(public_base_url) || public_base_url == "") {
    warning("MM_PUBLIC_BASE_URL is niet gezet. Gebruik Sys.setenv(MM_PUBLIC_BASE_URL='https://...') of geef het mee aan de functie.")
    # Fallback: enkel bestandsnaam
    return(basename(png_path))
  }
  
  base <- sub("/+$", "", public_base_url)  # trailing slash weg
  fname <- basename(png_path)
  
  url <- paste0(base, "/", fname)
  return(url)
}
