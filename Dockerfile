# build stage
FROM node:lts-alpine as build-stage
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# production stage
FROM nginx:stable-alpine as production-stage
COPY --from=build-stage /app/dist/kapalak /usr/share/nginx/html
COPY --from=build-stage /app/https.conf /etc/nginx/conf.d/https.conf
RUN apk add curl
RUN apk add openssl
RUN openssl req -x509 -nodes -days 365 -subj "/C=CA/ST=QC/O=Ecovadis, Inc./CN=localhost" -addext "subjectAltName=DNS:localhost.com" -newkey rsa:2048 -keyout /etc/nginx/nginx-selfsigned.key -out /etc/nginx/nginx-selfsigned.crt;
EXPOSE 80 443
CMD ["nginx", "-g", "daemon off;"]