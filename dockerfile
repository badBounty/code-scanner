FROM node:alpine3.10 as node

RUN apk add --update npm

RUN npm install -g retire

ENTRYPOINT ["retire"]