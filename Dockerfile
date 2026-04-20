FROM node:18-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install --omit=dev   # use this if no lock file

COPY app.js ./

USER node

EXPOSE 3000

CMD ["node", "app.js"]
