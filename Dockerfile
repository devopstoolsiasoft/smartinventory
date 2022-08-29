FROM smartinventoryproductions1/smartinventory
##########################
# Conjunto de parámetros de inicio 
##########################
ARG BUILD_ARGUMENT_DEBUG_ENABLED=false
ENV DEBUG_ENABLED=$BUILD_ARGUMENT_DEBUG_ENABLED
ARG BUILD_ARGUMENT_ENV=dev
ENV ENV=$BUILD_ARGUMENT_ENV
ENV APP_HOME /var/www/html/proyectoColombia
ENV APP_HTML /var/www/html

##########################
# Revisando el entorno para la aplicación
##########################
RUN if [ "$BUILD_ARGUMENT_ENV" = "default" ]; then echo "Set BUILD_ARGUMENT_ENV in docker build-args like --build-arg BUILD_ARGUMENT_ENV=dev" && exit 2; \
    elif [ "$BUILD_ARGUMENT_ENV" = "dev" ]; then echo "Building development environment."; \
    elif [ "$BUILD_ARGUMENT_ENV" = "test" ]; then echo "Building test environment."; \
    elif [ "$BUILD_ARGUMENT_ENV" = "prod" ]; then echo "Building production environment."; \
    else echo "Set correct BUILD_ARGUMENT_ENV in docker build-args like --build-arg BUILD_ARGUMENT_ENV=dev. Available choices are dev,test,prod." && exit 2; \
    fi
##########################
# Instalando las dependencia y habilitando los módulos PHP
##########################
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    procps \
    nano \
    git \
    unzip \
    libicu-dev \
    zlib1g-dev \
    libxml2 \
    libxml2-dev \
    libreadline-dev \
    supervisor \
    cron \
    libzip-dev \
    zip \
    curl \
    libbz2-dev \
    libpng-dev \
    libjpeg-dev \
    libmcrypt-dev \
    libreadline-dev \
    libfreetype6-dev \
    g++ \
    aptitude \
    build-essential \
    mariadb-client \
    python3 \
    python3-dev \
    libmariadbclient-dev \
    libmariadb-dev \
    python3-pip \
    && docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd \
    && docker-php-ext-configure gd --with-gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/ \
    && docker-php-ext-install \
    gd \
    mysqli \
    pdo_mysql \
    intl \      
    zip \ 
    gettext \
    bz2 \
    iconv \
    bcmath \
    opcache \
    calendar \
    mbstring \
    exif && \
    rm -fr /tmp/* && \
    rm -rf /var/list/apt/* && \
    rm -r /var/lib/apt/lists/* && \
    apt-get clean

######################
# Librerias Python
######################
RUN pip3 install --upgrade pip
RUN pip3 install spyne==2.13.2a0
RUN pip3 install suds-py3
RUN pip3 install lxml
RUN pip3 install mysqlclient
RUN pip3 install mysql
RUN pip3 install PyMySQL
RUN pip3 install pymssql
RUN pip3 install Cython
RUN pip3 install Patsy
RUN pip3 install scipy
RUN pip3 install statsmodels
RUN pip3 install sklearn
RUN pip3 install pysqldf
RUN pip3 install pandasql
RUN pip3 install matplotlib
RUN pip3 install pmdarima

##RUN docker-php-ext-install gettext
##########################
# Deshabilitado el sitio por defecto y borrando los archivos del directorio home
##########################
RUN a2dissite 000-default.conf
#Cambiado 08-04
##RUN rm -r $APP_HOME

##########################
# Creando el documento raíz
##########################
RUN mkdir -p $APP_HOME/public

##########################
# cambiando el UI al usuario por defecto
##########################
RUN usermod -u 1000 www-data && groupmod -g 1000 www-data
RUN chown -R www-data:www-data $APP_HOME

##########################
# Colocando la configuración de laravel para smartinv
########################## 
COPY ./docker/general/apache2.conf /etc/apache2/apache2.conf
COPY ./docker/general/laravel.conf /etc/apache2/sites-available/laravel.conf
COPY ./docker/general/laravel-ssl.conf /etc/apache2/sites-available/laravel-ssl.conf
RUN a2ensite laravel.conf && a2ensite laravel-ssl
COPY ./docker/$BUILD_ARGUMENT_ENV/php.ini /usr/local/etc/php/php.ini

##########################
# Habilitando los módulos de apache
##########################
RUN a2enmod rewrite
RUN a2enmod ssl

##########################
# Intalando Xdebug en caso de Desarrollo o pruebas de entorno
########################## 
COPY ./docker/general/do_we_need_xdebug.sh /tmp/
COPY ./docker/dev/xdebug.ini /tmp/
RUN chmod u+x /tmp/do_we_need_xdebug.sh && /tmp/do_we_need_xdebug.sh

##########################
# Instalando el composer
########################## 
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer

##########################
# agregando el supervisor
##########################
RUN mkdir -p /var/log/supervisor
COPY --chown=root:root ./docker/general/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY --chown=root:root ./docker/general/cron /var/spool/cron/crontabs/root
RUN chmod 0600 /var/spool/cron/crontabs/root
COPY --chown=www-data:www-data ./docker/index_html.php $APP_HTML/index.php

##########################
# Generando los certificado
# TODO: adécualo dependiendo de la aplicación
##########################
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/ssl-cert-snakeoil.key -out /etc/ssl/certs/ssl-cert-snakeoil.pem -subj "/C=AT/ST=Vienna/L=Vienna/O=Security/OU=Development/CN=example.com"

##########################
# Asignando el directorio de trabajo
##########################
WORKDIR $APP_HOME

# Creando la carpeta composer para el usuario www-data
RUN mkdir -p /var/www/.composer && chown -R www-data:www-data /var/www/.composer
USER www-data

# copiando los archivos fuentes y los de configuración
COPY --chown=www-data:www-data . $APP_HOME/
COPY --chown=www-data:www-data .env.$ENV $APP_HOME/.env

# Instalando las dependencias de laravel
RUN cd $APP_HOME && composer update
# RUN if [ "$BUILD_ARGUMENT_ENV" = "dev" ] || [ "$BUILD_ARGUMENT_ENV" = "test" ]; then composer install --no-interaction --no-progress; \
#     else composer install --no-interaction --no-progress --no-dev; \
#     fi

USER root