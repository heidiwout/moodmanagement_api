
upload_to_github <- function(png_path) {
  github_repo   <- Sys.getenv("GITHUB_REPO")        # bv. "heidiwout/moodmanagement_profiles"
  github_branch <- Sys.getenv("GITHUB_BRANCH")      # meestal "main"
  gh_token      <- Sys.getenv("GH_TOKEN")
  public_base   <- Sys.getenv("MM_PUBLIC_BASE_URL") # GitHub Pages URL
  
  if (github_repo == "" | gh_token == "" | public_base == "") {
    stop("GitHub environment variables ontbreken.")
  }
  
  # naam van bestand bepalen
  fname <- basename(png_path)
  target_path <- fname  # rechtstreeks in repo root
  
  # PNG lezen en base64 encoderen
  file_bytes <- readBin(png_path, what = "raw", n = file.info(png_path)$size)
  file_base64 <- jsonlite::base64_enc(file_bytes)
  
  # API URL
  api_url <- paste0("https://api.github.com/repos/", github_repo, "/contents/", target_path)
  
  # PUT request naar GitHub
  res <- httr::PUT(
    url = api_url,
    httr::add_headers(Authorization = paste("token", gh_token)),
    body = list(
      message = paste("Add", fname),
      content = file_base64,
      branch = github_branch
    ),
    encode = "json"
  )
  
  if (httr::status_code(res) >= 300) {
    stop("GitHub upload mislukt: ", httr::content(res, as = "text"))
  }
  
  # URL teruggeven
  paste0(public_base, "/", fname)
}
