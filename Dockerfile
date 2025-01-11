FROM ubuntu:latest
ENV DEBIAN_FRONTEND noninteractive

LABEL MAINTAINER="Amir Pourmand"

# Install necessary system dependencies
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    software-properties-common \
    locales \
    imagemagick \
    build-essential \
    zlib1g-dev \
    libv8-dev \
    g++ \
    wget \
    jupyter-nbconvert \
    inotify-tools \
    procps && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Add Brightbox PPA and install Ruby 3.3
RUN apt-add-repository ppa:brightbox/ruby-ng -y && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends \
    ruby3.3 \
    ruby3.3-dev \
    bundler && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Set Ruby 3.3 as the default Ruby version
RUN update-alternatives --install /usr/bin/ruby ruby /usr/bin/ruby3.3 1 && \
    update-alternatives --set ruby /usr/bin/ruby3.3 && \
    update-alternatives --install /usr/bin/gem gem /usr/bin/gem3.3 1 && \
    update-alternatives --set gem /usr/bin/gem3.3

# Verify Ruby and Bundler versions
RUN ruby --version && gem --version && bundler --version

# Configure locales
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen

# Set environment variables
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    JEKYLL_ENV=production

# Install Jekyll and Bundler
RUN gem install jekyll bundler

# Create Jekyll working directory
RUN mkdir /srv/jekyll

# Add Gemfile and install gems
ADD Gemfile /srv/jekyll

WORKDIR /srv/jekyll

# Pre-install mini_racer to handle native extension issues
RUN gem install mini_racer --platform=ruby && \
    bundle install --no-cache

# Expose port for Jekyll server
EXPOSE 8080

# Add entry point script
COPY bin/entry_point.sh /tmp/entry_point.sh

# Set default command
CMD ["/tmp/entry_point.sh"]
