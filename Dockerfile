FROM rocker/r-ver:4.3.1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libmagick++-dev \
    imagemagick \
    && rm -rf /var/lib/apt/lists/*

# Install R packages (important: separate installs!)
RUN R -e "install.packages('plumber', repos='https://cloud.r-project.org')"
RUN R -e "install.packages('jsonlite', repos='https://cloud.r-project.org')"
RUN R -e "install.packages('data.table', repos='https://cloud.r-project.org')"
RUN R -e "install.packages('stringr', repos='https://cloud.r-project.org')"

# magick MUST be installed after system libs
RUN R -e "install.packages('magick', repos='https://cloud.r-project.org')"

# Copy code
WORKDIR /app
COPY . /app

EXPOSE 8080

# Start plumber API
CMD ["R", "-e", "pr <- plumber::plumb('plumber.R'); pr$run(host='0.0.0.0', port=8080)"]
