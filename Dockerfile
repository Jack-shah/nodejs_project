#stage 1: Build the app
FROM awajid3/npmnodegit:1.0.0 AS build

# Set user and working directory
USER root
WORKDIR /app

# Copy the entire project
COPY . .

# Install dependencies and build
RUN cd nodejs-application && \
    npm install && \
    npm run build


# 🚀 Stage 2: Runtime image
FROM awajid3/npmnodegit:1.0.0 AS runtime

USER root
WORKDIR /app

# Copy only the built app from build stage
COPY --from=build /app/nodejs-application/node_modules /app/node_modules
COPY --from=build /app/nodejs-application/dist /app/dist

# Expose the port your app uses
EXPOSE 18000

# Run the app
ENTRYPOINT ["node", "/app/dist/src/index.js"]
