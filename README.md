I started this project by first making a docker agent
for this i took ubuntu image.......... exec into it as root user
installed nodejs, and npm on it
then i created a image from this............
for this  docker commit  <contianerid> awajid3/npmnodegit:1.0.0
then i docker login and docker push to upload it on docker hub
In jenkinsfile i used this image as a docker agent for runnning my job in jenkins.
in the Jenkinsfile2 you can see that i have :
Installed depnedencies.............. npm look for package.json file for installing dependencies....... or any target(as in maven) 
RUN the target........ npm run build........
As output  i got a /dist folder in my project root 

/dist/src/index.js...................... is main file which is executed for running the app

for this we can locally check if its working by running   # node dist/src/index.js                this will give you aurl to access the website

Now i focused on creating a docker file from it

As i know for creating a dockerfile  we need to know
1 file stacks
2.  What is needed for its build.........(prerequisites tools, source code, command to build, ...........)       and what we get after build  artifact.........
3..  And the last what it needed to run............. run time env............ as its node app ............. it will need node  only.............. not npm


As we have seen  no artifact was built above  only the output folder /dist was created ..........

so for docker image...... w only need that folder to run the application as ....... it have all the necessary file)

FROM ubuntu

WORKDIR /app

RUN apt-get update  && apt get install nodejs  -y

COPY  /dist    .

ENTRPOINT["node" , "/src/index.js"]



or 



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
COPY --from=build /app/dist /app
EXPOSE 18000
ENTRYPOINT ["node", "/app/src/index.js"]



