FROM alpine

FROM php:7.2-apache

RUN apt-get clean
RUN apt-get update --fix-missing

RUN apt-get install -y \
    sudo \
    autoconf \
    autogen \
    wget \
    curl \
    rsync \
    ssh \
    openssh-client \
    git \
    nano \
    vim \
    emacs \
    goaccess \
    build-essential \
    apt-utils \
    software-properties-common \
    nasm \
    libjpeg-dev \
    libpng-dev \
    rbenv \
    ruby-build \
    imagemagick \
    libmagick++-dev \
    locales && \
    locale-gen en_US.UTF-8 && \
    localedef -i en_US -f UTF-8 en_US.UTF-8

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Set the timezone.
RUN sudo echo "America/New_York" > /etc/timezone
RUN sudo dpkg-reconfigure -f noninteractive tzdata

# Composer
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer && \
    chmod +x /usr/local/bin/composer && \
    composer self-update --preview
RUN command -v composer


## ssh
ENV SSH_PASSWD "root:Docker!"
RUN apt-get update \
        && apt-get install -y --no-install-recommends dialog \
        && apt-get update \
	&& apt-get install -y --no-install-recommends openssh-server \
	&& echo "$SSH_PASSWD" | chpasswd

# copy files needed to start docker
COPY .docker/sshd_config /etc/ssh/
COPY .docker/init.sh /usr/local/bin/
RUN chmod u+x /usr/local/bin/init.sh
ADD .docker/uml-gitwrapper.conf /etc/apache2/sites-available/uml-gitwrapper.conf

# Copy Jekyll src files
COPY .  /var/www/html/

# Install zip extension, composer needs it
RUN sudo docker-php-ext-install zip
RUN cd /var/www/html/ && composer install && composer dump-autoload && composer update


# Set global git user
RUN git config --global user.email "webmaster.lib@miami.edu"
RUN git config --global user.name "WADTeam"

# expose local and network ports
EXPOSE 2222 80

ENTRYPOINT ["/usr/local/bin/init.sh"]