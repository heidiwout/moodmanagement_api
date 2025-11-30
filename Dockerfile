FROM rocker/r-ver:4.3.1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libsodium-dev \
    libmagick++-dev \
    imagemagick \
    && rm -rf /var/lib/apt/lists/*

# Install R packages
RUN R -e "install.packages('plumber', repos='https://cloud.r-project.org')"
RUN R -e "install.packages('jsonlite', repos='https://cloud.r-project.org')"
RUN R -e "install.packages('data.table', repos='https://cloud.r-project.org')"
RUN R -e "install.packages('stringr', repos='https://cloud.r-project.org')"
RUN R -e "install.packages(c('httr','gh'), repos='https://cloud.r-project.org')"

# magick must come after system libs
RUN R -e "install.packages('magick', repos='https://cloud.r-project.org')"

# copy code
WORKDIR /app
COPY . /app

EXPOSE 8080

CMD ["R", "-e", "pr <- plumber::plumb('plumber.R'); pr$run(host='0.0.0.0', port=8080)"]
