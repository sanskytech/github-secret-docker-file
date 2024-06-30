FROM node:20-alpine AS build
# Install dependencies only when needed
# Check https://github.com/nodejs/docker-node/tree/b4117f9333da4138b03a546ec926ef50a31506c3#nodealpine to understand why libc6-compat might be needed.
RUN apk add --no-cache libc6-compat
WORKDIR /app
# Copy and install the dependencies for the project


COPY  ./package*.json /app/

RUN npm install -g npm@latest 
#    npm install --production && \
# RUN  npm install

RUN npm ci 

# Copy all other project files to working directory
COPY . .

# Set the environment variable from the secret file

RUN  --mount=type=secret,id=NEXT_PUBLIC_MY_SECRET   \
sed -i "s~NEXT_PUBLIC_MY_SECRET=~NEXT_PUBLIC_MY_SECRET=$(cat /run/secrets/NEXT_PUBLIC_MY_SECRET)~" .env.production


# Run the next build process and generate the artifacts
RUN npm run build 

# we are using multi stage build process to keep the image size as small as possible
FROM node:20-alpine
# update and install latest dependencies, add dumb-init package
# add a non root user
RUN apk update && apk upgrade && apk add dumb-init && adduser -D nextuser 

# set work dir as app
WORKDIR /app
# copy the public folder from the project as this is not included in the build process
# COPY --from=build --chown=nextuser:nextuser /app/public ./public
# copy the standalone folder inside the .next folder generated from the build process 
COPY --from=build --chown=nextuser:nextuser /app/.next/standalone ./
# copy the static folder inside the .next folder generated from the build process 
COPY --from=build --chown=nextuser:nextuser /app/.next/static ./.next/static
# set non root user
USER nextuser

# expose 3020 on container
EXPOSE 3020

ENV NEXT_PRIVATE_STANDALONE true
# set app host ,port and node env 
ENV HOST=0.0.0.0 PORT=3020 NODE_ENV=production
# start the app with dumb init to spawn the Node.js runtime process
# with signal support
CMD ["dumb-init","node","server.js"]
