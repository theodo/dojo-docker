FROM node:12.13-alpine

WORKDIR /usr/src/backend

# Install dependencies
RUN apk update && apk --no-cache add nginx && rm -rf /var/cache/apk/*

# Create necessary dir for nginx (it throws an error otherwise)
RUN mkdir /run/nginx

ENV NODE_ENV=production
ENV TYPEORM_ENTITIES=dist/**/*.entity.js,dist/src/**/*.entity.js
ENV TYPEORM_MIGRATIONS=dist/migration/*.js
ENV TYPEORM_MIGRATIONS_DIR=migration
ENV TYPEORM_SYNCHRONIZE=false

COPY ./nginx.conf /etc/nginx/nginx.conf
COPY package.json package.json
COPY yarn.lock yarn.lock

RUN apk --no-cache add --virtual builds-deps build-base python3 && yarn install --prod && yarn cache clean && apk del builds-deps && rm -rf /var/cache/apk/* /root/.cache /tmp/*

COPY ./dist ./dist

EXPOSE 80 443
CMD sh -c "yarn start:prod & nginx -g 'daemon off;'"
