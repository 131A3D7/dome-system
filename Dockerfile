ARG NPM_REGISTRY=http://registry.npmjs.org
FROM node:14 as builder
ARG NPM_REGISTRY
WORKDIR /app/aquar_home/aquar_home_front
COPY ./aquar_home_front/ ./
RUN npm install --registry ${NPM_REGISTRY}
RUN npm run build
WORKDIR /app/aquar_home/aquar_home_server
COPY ./aquar_home_server/ ./
RUN npm install --unsafe-perm --registry ${NPM_REGISTRY}
WORKDIR /app/aquar_home
RUN rm -rf ./aquar_home_server/public/ && mkdir -p aquar_home_server/public/ && cp -r ./aquar_home_front/dist/* ./aquar_home_server/public/

FROM node:14
RUN npm install -g pm2
WORKDIR /app/aquar_home
COPY --from=builder /app/aquar_home/aquar_home_server/ .
COPY --from=builder /app/aquar_home/aquar_home_server/db.json /var/aquar_data/db.json
EXPOSE 3000
VOLUME ["/var/aquardata"]
VOLUME ["/opt/aquarpool"]
CMD ["/bin/bash", "-c", "cd /app/aquar_home/ && mkdir -p /var/aquardata/log/ && npm run prd > /var/aquardata/log/aquar_home.log 2>&1"]
