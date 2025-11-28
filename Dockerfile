FROM rocker/r-ver:4.3.1

# Install system libraries for magick and image processing
RUN apt-get update && apt-get install -y \
    libmagick++-dev \
    imagemagick \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    && rm -rf /var/lib/apt/lists/*

# Install R packages
RUN R -e "install.packages(c('plumber', 'jsonlite', 'data.table', 'stringr'), repos='https://cloud.r-project.org')"

# Install magick separately AFTER system libs are installed
RUN R -e "install.packages('magick', repos='https://cloud.r-project.org')"

# Copy project files
WORKDIR /app
COPY . /app

# Expose plumber API port
EXPOSE 8080

# Start API
CMD ["R", "-e", "pr <- plumber::plumb('plumber.R'); pr$run(host='0.0.0.0', port=8080)"]
