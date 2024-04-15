FROM nginx:alpine
WORKDIR /var/www

# Compose overrides these with a bind mount for easy dev.
COPY ./ /var/www
COPY ./nginx/default.conf /etc/nginx/conf.d/default.conf
