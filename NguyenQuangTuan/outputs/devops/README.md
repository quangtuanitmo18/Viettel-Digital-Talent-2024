# Deploying a Web Application using DevOps Tools & Practices

## 1. Containerization

### 1.1 Description

Containerization is a technology that allows applications to be packaged and deployed along with all necessary libraries, configurations, and dependencies into separate containers. Containerization ensures that an application runs consistently on any environment—from a developer's personal computer to a production server.

Advantages:

- **Portability:** Containers allow an application to run consistently across environments, from local machines to production servers.
- **Resource Efficiency:** Containers use fewer resources than virtual machines since they share the host operating system’s kernel.
- **Speed:** Containers start up much faster than virtual machines, improving development and deployment speed.
- **Isolation:** Each container runs in an isolated environment, preventing application conflicts and enhancing security.
- **Version Control:** Images can be versioned like source code, making it easy to track and roll back to previous versions.

<div align="center">
  <img width="600" src="./assets/images/containerization.png" alt="containerization">
</div>

<div align="center">
  <i><a href="https://aws.amazon.com/vi/what-is/containerization/?nc1=f_ls">
         Containerization
    </a></i>
</div>

#### 1.1.1 Docker

Docker is an open-source containerization platform that allows you to create, deploy, and run applications in containers. Docker leverages Linux features such as cgroups and namespaces to run lightweight, isolated containers separate from each other and the host OS.

Main Components of Docker:

- **Docker Engine:** The core tool of Docker that provides the ability to create, deploy, and manage containers.
- **Docker Images:** Immutable templates of a container that contain everything needed to run an application (source code, runtime, libraries, environment variables, etc.).
- **Docker Containers:** An instance of a Docker image running in a standalone runtime environment.
- **Docker Registry:** A service that stores Docker images and allows sharing them among users.

<div align="center">
  <img width="600" src="./assets/images/architecture-of-docker.png" alt="Architecture of Docker">
</div>

<div align="center">
  <i><a href="https://www.geeksforgeeks.org/architecture-of-docker/">
         Architecture of Docker
        </a></i>
</div>

#### 1.1.2 Docker Compose

Docker Compose is a tool used to define and manage multi-container Docker applications. With Docker Compose, you can use a YAML file to define the services, networks, and volumes of an application and then use a single command to create and run everything.

<div align="center">
  <img width="600" src="./assets/images/docker-compose.png" alt="Docker compose">
</div>

<div align="center">
  <i><a href="https://docs.docker.com/compose">
         Docker Compose
    </a></i>
</div>

### 1.2 Output

#### 1.2.1 Docker and Docker Compose Files for Each Service

The [docker](https://github.com/quangtuanitmo18/VDT-midterm-api/blob/main/Dockerfile.local) and [docker compose](https://github.com/quangtuanitmo18/VDT-midterm-api/blob/main/docker-compose.local.yml) files for the API and database services:

**Docker file for the API service uses:**

- **Multi-Stage Build:** To optimize the final image size. Multi-stage builds allow using multiple FROM commands in a Dockerfile. Each FROM starts a new build stage.
  - **Builder Stage:** This stage installs dependencies, copies necessary files, and builds the application.
  - **Start Stage:** This stage creates the final image, including only the necessary files and runtime dependencies.
- **Layer Caching:** Docker caches the result of each command in the Dockerfile to speed up the build process. If a layer does not change, Docker reuses the cached version.
  - **Optimized Copy:** By copying only necessary files and executing build commands in separate steps, Docker ensures that changes in source code do not invalidate cached layers for dependencies, speeding up the build process.
- **Non-Root User:** Creating and switching to a non-root user (appuser) improves security by ensuring the application does not run with root privileges.

**_Dockerfile_**

```shell
# Build stage
FROM node:20-alpine3.16 AS builder

WORKDIR /app

## Copy package files and install dependencies
COPY package*.json ./
RUN npm install

## Copy other necessary files
COPY tsconfig.json .
COPY ecosystem.config.js .
COPY .env.development .
COPY ./src ./src

## Build the application
RUN npm run build

# Start stage
FROM node:20-alpine3.16

WORKDIR /app

## Install Python and PM2 globally
RUN apk add --no-cache python3 && \
    npm install pm2 -g

## Create a non-root user and switch to it
RUN adduser -D appuser

## Copy built artifacts and other necessary files from the builder stage
COPY --from=builder /app .
RUN chown -R appuser:appuser /app

## Expose the port the app runs on
EXPOSE 4000

## Command to run the app
CMD ["pm2-runtime", "start", "ecosystem.config.js"]
```

<br>

The docker-compose file includes the deployment for the API and database services:

- **API Service**

  - **container_name:** Names the container as vdt-midterm-api.
  - **build:**
    - **context:** Sets the build context to the current directory (./).
    - **dockerfile:** Specifies the Dockerfile as Dockerfile.local.
  - **ports:** Exposes port 4000 on the host and maps it to port 4000 in the container.
  - **restart:** Configures the container to always restart on failure.
  - **image:** Names the image as vdt-midterm-api:v1.
  - **env_file:** Specifies the .env.development file to pass environment variables to the container.
  - **networks:** Joins the app-network.
  - **depends_on:** Ensures that the database service starts before the API service.

- **Database Service**

  - **container_name:** Names the container as vdt-midterm-db.
  - **image:** Uses the latest MongoDB image (mongo:latest).
  - **ports:** Exposes port 27017 on the host and maps it to 27017 in the container.
  - **volumes:** Attaches the mongodb_data volume on the host to the /data/db directory in the container to persist the MongoDB data.
  - **environment:** Sets environment variables for MongoDB:
    - MONGO_INITDB_ROOT_USERNAME: Root username (mongo_user).
    - MONGO_INITDB_ROOT_PASSWORD: Root password (mongo_password).
  - **restart:** Configures the container to always restart on failure.
  - **networks:** Joins the app-network.

- **Network**
  - **app-network:** [Definition of the app-network](./assets/docs/docker-network.md) defines an external network (external), meaning it is pre-created outside the Docker Compose file and will be reused.

**_docker-compose_**

```shell
version: '3.8'
services:
  api:
    container_name: vdt-midterm-api
    build:
      context: ./
      dockerfile: Dockerfile.local
    ports:
      - '4000:4000'
    restart: always
    image: vdt-midterm-api:v1
    env_file:
      - ./.env.development
    networks:
      - app-network
    depends_on:
      - db
  db:
    container_name: vdt-midterm-db
    image: mongo:latest
    ports:
      - '27017:27017'
    volumes:
      - mongodb_data:/data/db
    environment:
      MONGO_INITDB_ROOT_USERNAME: mongo_user
      MONGO_INITDB_ROOT_PASSWORD: mongo_password
    restart: always
    networks:
      - app-network
networks:
  app-network:
    external: true

volumes:
  mongodb_data:
```

<br>

**Docker and docker-compose files for the Web service**  
Similarly to the above, the web service uses Nginx as its web server to deploy the service. Nginx is a high-performance, open-source web server. Today, Nginx has become one of the most popular web servers worldwide. Not only does Nginx serve as a web server, but it can also act as a reverse proxy, load balancer, and HTTP cache.

**_Dockerfile_**

```shell
# Stage 1: Build the React application
FROM node:20-alpine3.16 as build

## Set the working directory in the container
WORKDIR /app

## Copy the package.json and package-lock.json (or yarn.lock)
COPY package*.json ./

## Install dependencies
RUN npm install

## Copy the rest of your app's source code from your host to your image filesystem.
COPY . .

## Build the project
RUN npm run build

# Stage 2: Serve the app with Nginx
FROM nginx:stable-alpine

## Copy the built files from the build stage to the Nginx server
COPY --from=build /app/dist /usr/share/nginx/html

## Expose port 80 to the outside once the container has launched
EXPOSE 80

## Define the command to run your app using CMD which defines your runtime
CMD ["nginx", "-g", "daemon off;"]
```

**_docker-compose_**

```shell
version: '3.8'
services:
  web:
    container_name: vdt-midterm-web
    build: ./
    ports:
      - '3000:80'
    restart: always
    image: vdt-midterm-web:v1
    env_file:
      - .env
    networks:
      - app-network

networks:
  app-network:
    external: true
```

<br>

#### 1.2.2 Output: Build Commands and Docker History of Each Image

**Output of the build command via docker-compose**

<div align="center">
  <img width="600" src="./assets/images/docker-compose-api-db.png" alt="Docker compose api and db">
</div>

<div align="center">
  <i>vdt-midterm-api</i>
</div>
<br>

<div align="center">
  <img width="600" src="./assets/images/docker-compose-web.png" alt="Docker compose web">
</div>

<div align="center">
  <i>vdt-midterm-web</i>
</div>

**Docker history of each image**

<div align="center">
  <img width="600" src="./assets/images/docker-history-api.png" alt="Docker history api">
</div>

<div align="center">
  <i>Docker history of image vdt-midterm-api</i>
</div>
<br>

<div align="center">
  <img width="600" src="./assets/images/docker-history-web.png" alt="Docker history web">
</div>

<div align="center">
  <i>Docker history of image vdt-midterm-web</i>
</div>
<br>

<div align="center">
  <img width="600" src="./assets/images/docker-history-db.png" alt="Docker history db">
</div>

<div align="center">
  <i>Docker history of image mongo</i>
</div>
<br>

## 2. CI/CD (1.5 Points)

### 2.1 Description

CI/CD stands for Continuous Integration and Continuous Delivery/Deployment, which is an automated process that accelerates product development and delivers the product to end users. CI/CD is widely applied in IT companies’ workflows, alongside DevOps and Agile methodologies.

**Continuous Integration (CI)**

Continuous Integration is a software development practice in which code changes are frequently merged into the main branch. This process involves:

- **Frequent integration:** Developers regularly push code changes to a shared repository.
- **Automated builds:** Each code change triggers an automated build process to verify that the code compiles and builds without errors.
- **Automated testing:** Automated tests (unit tests, integration tests) are executed to ensure the new changes do not introduce errors.

**Continuous Deployment/Continuous Delivery (CD)**

The process includes:

- **Automated deployment:** Once the code passes all tests, it is ready to be deployed to various environments.
- **Monitoring and feedback:** Continuous monitoring detects and handles issues after deployment.

Differences between Continuous Deployment and Continuous Delivery:

- **Continuous Deployment:** Automatically deploys code after it passes all tests, without manual intervention.
- **Continuous Delivery:** The code is ready to be deployed after passing tests, but manual intervention is required to trigger the final deployment.

<div align="center">
  <img width="600" src="./assets/images/ci-cd.png" alt="CI/CD">
</div>

<div align="center">
  <i>CI/CD</i>
</div>
<br>

Advantages of CI/CD:

- **Enhanced Agility:** Speeds up the development and deployment process.
- **Risk Reduction:** Automated testing and deployment help detect and fix errors quickly.
- **Improved Collaboration:** Continuous integration and frequent code sharing improve team collaboration.
- **Quality Assurance:** Automated tests and continuous deployment ensure higher code quality and fewer bugs reach end users.

Disadvantages of CI/CD:

- **Initial Complexity:** Setting up a CI/CD system can be time-consuming and complex.
- **Costs:** Setting up and maintaining a CI/CD system may incur costs, especially for large projects.

### 2.2 Output

**Resource Preparation**

For example, [Using Vagrant to create virtual machines](./assets/docs/vagrant-vm-setup.md)

To deploy a CICD Pipeline in this project, the following resources are required. The servers below run on Ubuntu Focal 20.04:

- **Server 1: CI/CD QA Server (cicd-qa-server):** Memory: 3 GB, Processor: 1 – IP: `192.168.64.140`
  - Port `8080` – Jenkins server
  - Port `9000` – Sonarqube server
- **Server 2: Gitlab Server (gitlab-server):** Memory: 3 GB, Processor: 1 – IP: `192.168.64.141`
- **Server 3: App Server 1 (app-server-1):** Memory: 1 GB, Processor: 1 – IP: `192.168.64.142`
- **Server 4: Database Server (database-server):** Memory: 1 GB, Processor: 1, Disk: 20 GB – IP: `192.168.64.143`
- **Server 5: App Server 2 (app-server-2):** Memory: 1 GB, Processor: 1 – IP: `192.168.64.144`
- **Server 6: Load Balancing Server (lb-server):** Memory: 1 GB, Processor: 1 – IP: `192.168.64.145`
- **Server 7: Docker Registry:** Uses **Docker Hub**

**Initial Setup on the Servers**

- [Setup Gitlab Server](./assets/docs/gitlab-server-setup.md)
- [Setup Jenkins Server](./assets/docs/jenkins-server-setup.md)
- [Setup Sonarqube Server](./assets/docs/sonarqube-server-setup.md)
- [Setup Database Server](./assets/docs/database-server-setup.md)
- [Setup Nginx Server as Load Balancer](./assets/docs/nginx-server-setup.md)
- [Setup Docker Hub](./assets/docs/dockerhub-setup.md)
- [Install Docker and docker-compose](./assets/docs/docker-setup.md)

#### 2.2.1 CI/CD Pipeline Configuration

To run the CI/CD pipeline as required:

- Automatically trigger when a PR is created on the main branch.
- Automatically trigger when commits are pushed to any branch.

Below is the Gitlab webhook configuration for the `VDT-midterm-api` repository and the pipeline configuration `pipeline-vdt-midterm-api` on Jenkins for the API service. The configuration for the web service is similar.

**Gitlab Repository Webhook Configuration**  
In the project, go to `Settings -> Webhooks` and configure as follows:  
`URL: http://<jenkins_account>:<jenkins_token>@<jenkins_address>/project/<jenkins_project_name>`

For the `VDT-midterm-api` webhook, the URL is:  
`http://jenkins-admin:1197fee3ac6455760068658062a4cbda6a@192.168.64.140:8080/project/pipeline-vdt-midterm-api`

<div align="center">
  <img width="800" src="./assets/images/gitlab-webhook-1.png" alt="Network setting">
</div>
<div align="center">
  <img width="800" src="./assets/images/gitlab-webhook-api.png" alt="Network setting">
</div>

**Jenkins Pipeline Configuration**  
Go to `Dashboard -> pipeline-vdt-midterm-api -> configuration` and under `Build Triggers` configure as shown below:

<div align="center">
  <img width="800" src="./assets/images/jenkins-config-pipeline-2.png" alt="">
</div>
<br>

Under `Branches To Build`, select main and release. This ensures that Jenkins only runs the pipeline when a merge request or push is made from these two branches, and not for every branch.

<div align="center">
  <img width="800" src="./assets/images/jenkins-config-pipeline-5.png" alt="">
</div>
<br>

With the above trigger configurations on both Gitlab and Jenkins, the requirements are met. Detailed setup steps are provided in section `2.2.1`.

<br>

#### 2.2.2 CI/CD Pipeline on Jenkins

The Jenkins credentials created for the pipeline include:

- **gitlab-api-token:** Token created by an admin user on Gitlab.
- **gitlab-credential:** An account with admin privileges on Gitlab.
- **sonarqube-token:** Token created by an admin user on Sonarqube.
- **sonar-host-url:** URL to access the Sonarqube server at `192.168.64.140:9000`
- **vdt-midterm-web-project-key:** Project key for the `vdt-midterm-web` project on Sonarqube.
- **vdt-midterm-api-project-key:** Project key for the `vdt-midterm-api` project on Sonarqube.
- **jenkins-ssh-key:** Private SSH key created to SSH into `app-server-1` and `app-server-2`.
- **dockerhub-credential:** Docker Hub account.
- **telegram-token:** Token generated by `BotFather` on Telegram.
- **telegram-chatId:** Chat ID of the Telegram bot.
- **ip-app-server-1:** `192.168.64.142`
- **ip-app-server-2:** `192.168.64.144`
- **vdt-midterm-api-env:** Environment file for the production environment of the `web` service.
- **vdt-midterm-web-env:** Environment file for the production environment of the `api` service.

<div align="center">
  <img width="1000" src="./assets/images/jenkins-credentials.png" alt="">
</div>
<div align="center">
  <i>Jenkins Credentials</i>
</div>
<br>

**Below is the CI/CD pipeline for the API service; the pipeline for the web service is similar:**

- `def deployToServer(serverAddress)`: This function deploys the application to a specific server via SSH and Docker.
  - `deploying`: A bash command string to remove the current Docker container, pull the new Docker image from Docker Hub, and run a new container.
  - `sshagent`: Uses an SSH key to connect to the remote server and execute the deployment script.
- `def sendTelegramMessage(token, chatId, message)`: This function sends a message to Telegram.
  - `sh`: Executes a curl command to send the message via Telegram’s API.
- `pipeline`
  - `agent any`: Specifies that the pipeline can run on any available Jenkins agent.
  - `environment`: Declares environment variables needed for the pipeline.
  - `stages`: Contains steps in the pipeline process:
    - **Prepare pipeline:** Sends a Telegram message to indicate the build start.
    - **Checkout source:** Clones the source code into the project folder, adjusts file ownership and permissions.
    - **Test with SonarQube:** Runs code analysis with SonarQube.
    - **Check lint and prettier:** Installs npm dependencies and runs linting and code formatting checks with Prettier.
    - **Unit test with Jest:** Reads the environment file and executes unit tests with Jest.
    - **Build and push image:**
      - Checks if the commit has a tag. If so, it asks the user if they want to build and push the Docker image to Docker Hub.
      - If the user chooses "Yes", the Docker image is built and pushed to Docker Hub.
    - **Deploy:**
      - Checks if the commit has a tag. If so, it asks for user confirmation to deploy.
      - If confirmed, the application is deployed to the designated servers.
  - `post`: Sends a Telegram notification based on the pipeline’s outcome:
    - **success:** Sends a success message.
    - **failure:** Sends a failure message.
    - **aborted:** Sends an aborted message.

```shell
def deployToServer(serverAddress) {
    def deploying = "#!/bin/bash \n" +
        "docker rm -f ${NAME_API} \n" +
        "docker pull ${DOCKER_HUB}/${NAME_API}:$DOCKER_TAG \n" +
        "docker run --name=${NAME_API} -d -p 4000:4000 ${DOCKER_HUB}/${NAME_API}:$DOCKER_TAG"

    sshagent(credentials: ['jenkins-ssh-key']) {
        sh """
            ssh -o StrictHostKeyChecking=no -i jenkins-ssh-key tuan@$serverAddress "echo \\\"${deploying}\\\" > deploy-api.sh \
            && chmod +x deploy-api.sh && ./deploy-api.sh  && exit"
        """
    }
}
def sendTelegramMessage(token, chatId, message) {
    sh """
    curl -s -X POST https://api.telegram.org/bot${token}/sendMessage -d chat_id=${chatId} -d text="${message}"
    """
}

pipeline{
    agent any
    environment{
        PATH_PROJECT = '/home/projects/VDT-midterm-api'

        SONAR_PROJECT_KEY = credentials('vdt-midterm-api-sonar-project-key')
        SONAR_TOKEN = credentials('sonarqube-token')
        SONAR_HOST_URL= credentials('sonar-host-url')

        DOCKER_HUB ='tuanquang1811'
        DOCKER_HUB_CREDENTIALS = credentials('dockerhub-credentials')
        NAME_API = 'vdt-midterm-api'
        DOCKER_TAG = "${GIT_BRANCH.tokenize('/').pop()}-${GIT_COMMIT.substring(0,7)}"

        ENV_FILE_VDT_MIDTERM_API = ''

        TELEGRAM_TOKEN = credentials('telegram-token')
        TELEGRAM_CHAT_ID = credentials('telegram-chatId')
        TEXT_PRE_BUILD = "Jenkins is building ${JOB_NAME}"

        IP_APP_SERVER_1 = credentials('ip-app-server-1')
        IP_APP_SERVER_2 = credentials('ip-app-server-2')
    }
    stages{

        stage("Prepare pipeline") {
            steps {
                script {
                    sendTelegramMessage(TELEGRAM_TOKEN, TELEGRAM_CHAT_ID, TEXT_PRE_BUILD)
                }
            }
        }
        stage('Checkout source' ){
            steps{
                sh "sudo cp -r . $PATH_PROJECT \
                && sudo chown -R jenkins:jenkins $PATH_PROJECT \
                && sudo chmod -R 755  $PATH_PROJECT \
                "
            }
        }
        stage('Test with sonarqube'){
            steps{
                withSonarQubeEnv('sonarqube connection') {
                    sh "cd $PATH_PROJECT && docker run --rm \
                    -e SONAR_HOST_URL=${SONAR_HOST_URL} \
                    -e SONAR_SCANNER_OPTS='-Dsonar.projectKey=${SONAR_PROJECT_KEY}' \
                    -e SONAR_TOKEN=${SONAR_TOKEN} \
                    -v '.:/usr/src' \
                    sonarsource/sonar-scanner-cli"
                }
            }
        }
        stage('Check lint and prettier'){
            steps{
                sh "cd $PATH_PROJECT && npm install && npm run lint && npm run prettier"
            }
        }
        stage('Unit test with Jest'){
            steps{
              script{
                 withCredentials([file(credentialsId: 'vdt-midterm-api-env', variable: 'ENV_FILE_VDT_MIDTERM_API')]) {
                                ENV_FILE_VDT_MIDTERM_API = readFile(file:"$ENV_FILE_VDT_MIDTERM_API").trim()
                }
                sh "echo \"$ENV_FILE_VDT_MIDTERM_API\" > $PATH_PROJECT/.env.production"
                sh "cd $PATH_PROJECT && npm run test:prod"
              }
            }
        }
        stage('Build and push image'){
           when {
                expression {
                     return sh(script: 'git describe --exact-match --tags HEAD', returnStatus: true) == 0
                }
            }
            steps{
                script {
                    try {
                        timeout(time: 3, unit: 'MINUTES') {
                            env.userChoice = input message: 'Do you want to build and push image to docker hub?',
                                parameters: [choice(name: 'Versioning service', choices: 'Yes\nNo', description: 'Choose "Yes" if you want to build and push image to docker hub')]
                        }
                        if(env.userChoice == 'Yes') {
                            env.IMAGE_TAG = DOCKER_TAG
                            sh " cd $PATH_PROJECT \
                            && IMAGE_TAG=${IMAGE_TAG} \
                            && NAME_API=${NAME_API} \
                            && docker-compose build --parallel \
                            && docker tag ${NAME_API}:$DOCKER_TAG ${DOCKER_HUB}/${NAME_API}:$DOCKER_TAG \
                            && echo $DOCKER_HUB_CREDENTIALS_PSW | docker login -u $DOCKER_HUB_CREDENTIALS_USR --password-stdin \
                            && docker push ${DOCKER_HUB}/${NAME_API}:$DOCKER_TAG \
                            && docker rmi  ${DOCKER_HUB}/${NAME_API}:$DOCKER_TAG "
                        } else {
                            echo "build and push image to docker hub cancelled"
                        }
                    } catch(Exception err) {
                        def user = err.getCauses()[0].getUser()
                        if('SYSTEM' == user.toString()) {
                            def didTimeout = true
                            echo "Timeout. Build and push image to docker hub cancelled"
                        } else {
                            echo "Build and push image to docker hub cancelled by: ${user}"
                        }
                    }
                }
            }
        }
        stage('Deploy'){
            when {
                expression {
                     return sh(script: 'git describe --exact-match --tags HEAD', returnStatus: true) == 0
                }
            }
            steps{
                script{
                    try {
                        timeout(time: 3, unit: 'MINUTES') {
                            env.userChoice = input message: 'Do you want to deploy?',
                                parameters: [choice(name: 'Versioning service', choices: 'Yes\nNo', description: 'Choose "Yes" if you want to deploy')]
                        }
                        if(env.userChoice == 'Yes') {
                            deployToServer(IP_APP_SERVER_1)
                            deployToServer(IP_APP_SERVER_2)
                        } else {
                            echo "deploy cancelled"
                        }
                    }
                    catch(Exception err) {
                        def user = err.getCauses()[0].getUser()
                        if('SYSTEM' == user.toString()) {
                            def didTimeout = true
                            echo "Timeout. Deploy cancelled"
                        } else {
                            echo "Deploy cancelled by: ${user}"
                        }
                    }
                }
            }
        }
    }
    post{
        success {
            sendTelegramMessage(TELEGRAM_TOKEN, TELEGRAM_CHAT_ID, "JOB ${JOB_NAME} is Success")
        }
        failure {
            sendTelegramMessage(TELEGRAM_TOKEN, TELEGRAM_CHAT_ID, "JOB ${JOB_NAME} is Failure")
        }
        aborted {
            sendTelegramMessage(TELEGRAM_TOKEN, TELEGRAM_CHAT_ID, "JOB ${JOB_NAME} is Aborted")
        }
    }
}
```

<br>

The `.env.production` file for the API service ([repo link](https://github.com/quangtuanitmo18/VDT-midterm-api)):

```shell
# APP
HOST=http://192.168.64.145/api
PORT=4000
CLIENT_URL=http://192.168.64.145

# DB
DB_NAME=vdt-midterm
DB_NAME_TEST=vdt-midterm-test
DB_USERNAME=mongo_user
DB_PASSWORD=mongo_password
DB_HOST=192.168.64.143
DB_HOST_TEST=192.168.64.143
DB_PORT=27017
```

The `.env` file for the Web service ([repo link](https://github.com/quangtuanitmo18/VDT-midterm-web)):

```shell
VITE_API_URL="http://192.168.64.145/api"
```

#### 2.2.3 Demo Images

**Demo Images for the API Pipeline (`pipeline-vdt-midterm-api`)**

When pushing or creating a merge request to the `main` or `release` branch, the pipeline skips the `Build and push image` and `Deploy` stages due to the absence of a tag.

<div align="center">
  <img width="1000" src="./assets/images/jenkins-pipeline-api-9.png" alt="">
</div>

After creating a tag on the main branch of the `VDT-midterm-api` repo, the `Build and push image` and `Deploy` stages are executed manually for confirmation (Continuous Delivery).

<div align="center">
  <img width="1000" src="./assets/images/jenkins-pipeline-api-10.png" alt="">
</div>
<div align="center">
  <img width="1000" src="./assets/images/jenkins-pipeline-api-1.png" alt="">
</div>
<div align="center">
  <img width="1000" src="./assets/images/jenkins-pipeline-api-2.png" alt="">
</div>
<div align="center">
  <img width="1000" src="./assets/images/jenkins-pipeline-api-3.png" alt="">
</div>

Image pushed to Docker Hub:

<div align="center">
  <img width="1000" src="./assets/images/jenkins-pipeline-api-4.png" alt="">
</div>
<br>

SonarQube Code Analysis:

<div align="center">
  <img width="1000" src="./assets/images/jenkins-pipeline-api-5.png" alt="">
</div>
<br>

Docker image pulled and run on `app-server-1` and `app-server-2`:

<div align="center">
  <img width="1000" src="./assets/images/jenkins-pipeline-api-6.png" alt="">
</div>
<div align="center">
  <img width="1000" src="./assets/images/jenkins-pipeline-api-7.png" alt="">
</div>
<br>

Telegram Notification:

<div align="center">
  <img width="1000" src="./assets/images/jenkins-pipeline-api-8.png" alt="">
</div>
<br>

**Demo Images for the Web Pipeline (`pipeline-vdt-midterm-web`)**

When pushing or creating a merge request to the `main` or `release` branch, the pipeline skips the `Build and push image` and `Deploy` stages due to the absence of a tag.

<div align="center">
  <img width="1000" src="./assets/images/jenkins-pipeline-web-1.png" alt="">
</div>

After creating a tag on the main branch of the `VDT-midterm-web` repo, the `Build and push image` and `Deploy` stages are executed manually for confirmation (Continuous Delivery).

<div align="center">
  <img width="1000" src="./assets/images/jenkins-pipeline-web-11.png" alt="">
</div>
<div align="center">
  <img width="1000" src="./assets/images/jenkins-pipeline-web-2.png" alt="">
</div>
<div align="center">
  <img width="1000" src="./assets/images/jenkins-pipeline-web-3.png" alt="">
</div>
<div align="center">
  <img width="1000" src="./assets/images/jenkins-pipeline-web-4.png" alt="">
</div>
<div align="center">
  <img width="1000" src="./assets/images/jenkins-pipeline-web-5.png" alt="">
</div>
<br>

Image pushed to Docker Hub:

<div align="center">
  <img width="1000" src="./assets/images/jenkins-pipeline-web-6.png" alt="">
</div>
<br>

SonarQube Code Analysis:

<div align="center">
  <img width="1000" src="./assets/images/jenkins-pipeline-web-7.png" alt="">
</div>
<br>

Docker image pulled and run on `app-server-1` and `app-server-2`:

<div align="center">
  <img width="1000" src="./assets/images/jenkins-pipeline-web-8.png" alt="">
</div>
<br>
<div align="center">
  <img width="1000" src="./assets/images/jenkins-pipeline-web-9.png" alt="">
</div>
<br>

Telegram Notification:

<div align="center">
  <img width="1000" src="./assets/images/jenkins-pipeline-web-10.png" alt="">
</div>
<br>

**Browser Display Result**

Access the IP address `192.168.64.145` (that of the `lb-server`):

<div align="center">
  <img width="1000" src="./assets/images/web-test-1.png" alt="">
</div>
<br>

After creating tags on both the `VDT-midterm-api` and `VDT-midterm-web` repos, the pipelines (`pipeline-vdt-midterm-api` and `pipeline-vdt-midterm-web`) execute, and the new code is deployed on `app-server-1` and `app-server-2`.

<div align="center">
  <img width="1000" src="./assets/images/lb-schema.png" alt="Load balancing schema">
</div>
<div align="center">
  <i>Load Balancing Schema</i>
</div>
<br>

## 3. Automation

### 3.1 Description

Automation is the process of using technology to perform tasks or processes automatically, minimizing human intervention. Automation improves efficiency, reduces errors, and saves time in workflows.

Ansible is an open-source tool used for automating deployment, configuration management, and application orchestration. Ansible uses YAML to describe configurations and tasks, operating under the desired state model. It does not require the installation of agents on target nodes and interacts with servers via SSH.

Key features of Ansible include:

- **Declarative Configuration Management:** Describes the desired state of the system in YAML files, ensuring the system adheres to that state.
- **Idempotent Operations:** Ansible modules perform idempotent operations, meaning they can be run multiple times without affecting the system's state.
- **Infrastructure as Code (IaC):** Manages infrastructure as source code, enabling reproducible and flexible infrastructure setups.
- **Modularity and Reusability:** Tasks can be broken down into smaller elements called roles and playbooks, making them easy

### 3.2 Output

Installation steps for Ansible  
[VDT-midterm-ansible Repository](https://github.com/quangtuanitmo18/VDT-midterm-ansible)  
Install Ansible on the server `cicd-qa-server: 192.168.64.140`.

The directory containing the Ansible playbooks used for deploying the services includes:

- **inventory.ini:** Contains the list of hosts, organized into groups for deployment.
- **playbook.yml:** Defines the actions and procedures to be executed on target servers via roles.
- **roles directory:** Contains the following roles:
  - **docker:** Installs Docker and docker-compose.
  - **web:** Deploys the web service by pulling the Docker image from Docker Hub (created during CI/CD) and running it.
  - **api:** Deploys the API service by pulling the Docker image from Docker Hub (created during CI/CD) and running it.
  - **database:** Deploys the database service.
  - **nginx:** Installs the Nginx server.
  - **loadbalancing:** Deploys load balancing.

#### 3.2.1 Demo Images

Logs when running the playbook:

<div align="center">
  <img width="1000" src="./assets/images/ansible-log-1.png" alt="">
</div>
<div align="center">
  <img width="1000" src="./assets/images/ansible-log-2.png" alt="">
</div>
<div align="center">
  <img width="1000" src="./assets/images/ansible-log-3.png" alt="">
</div>
