# syntax=docker/dockerfile:1

FROM node:18-bullseye-slim
ENV NODE_ENV=production

RUN apt-get update && apt-get install -y ffmpeg
WORKDIR /app
COPY ["package.json", "package-lock.json*", "./"]
RUN npm install --production
RUN mkdir -p lib/js/src/main
RUN mkdir -p lib/node_modules
RUN mkdir -p resources
COPY ["./lib/js/src/main", "./lib/js/src/main"]
COPY ["./lib/node_modules", "./lib/node_modules"]
CMD [ "node", "./lib/js/src/main/Index.bs.js" ]

