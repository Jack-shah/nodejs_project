# Stage 1: Build the app
FROM awajid3/npmnodegit:1.0.0 AS build
USER root
WORKDIR /app
COPY . .
RUN npm install && npm run build


# Stage 2: Runtime image
FROM awajid3/npmnodegit:1.0.0 AS runtime
USER root
WORKDIR /app
# Copy only the built files
# here we only copy what in deist folder  we might need to copy the node_module folder as well 
COPY --from=build /app/dist /app                
EXPOSE 18000
ENTRYPOINT ["node", "/app/src/index.js"]
