# Triển khai web application sử dụng các DevOps tools & practices

## 1. Containerization

### 1.1 Mô tả

Containerization là một công nghệ cho phép đóng gói và triển khai ứng dụng cùng với tất cả các thư viện, cấu hình và phụ thuộc cần thiết vào một container riêng biệt. Container hóa giúp đảm bảo rằng ứng dụng sẽ chạy nhất quán trên bất kỳ môi trường nào, từ máy tính cá nhân của nhà phát triển đến máy chủ sản xuất.

Ưu điểm:

- Tính Di Động (Portability): Container cho phép ứng dụng chạy nhất quán trên mọi môi trường, từ máy tính cá nhân đến máy chủ sản xuất.
- Tối Ưu Tài Nguyên (Resource Efficiency): Containers sử dụng ít tài nguyên hơn so với các máy ảo vì chúng chia sẻ kernel của hệ điều hành chủ.
- Tốc Độ (Speed): Containers khởi động nhanh hơn nhiều so với máy ảo, giúp cải thiện tốc độ phát triển và triển khai.
- Tách Biệt (Isolation): Mỗi container chạy trong môi trường cách ly, giúp tránh xung đột giữa các ứng dụng và đảm bảo tính bảo mật.
- Quản Lý Phiên Bản (Version Control): images có thể quản lý phiên bản giống như mã nguồn, giúp dễ dàng theo dõi và quay lại phiên bản trước.

<div align="center">
  <img width="600" src="./assets/images/containerization.png" alt="containerization">
</div>

<div align="center">
  <i><a href=https://aws.amazon.com/vi/what-is/containerization/?nc1=f_ls>
         Contanerization
    </a></i>
</div>

#### 1.1.1 Docker

Docker là một nền tảng containerization mã nguồn mở, cho phép tạo, triển khai và chạy các ứng dụng trong các container. Docker sử dụng các tính năng cô lập của hệ điều hành Linux, như cgroups và namespaces, để chạy các container nhẹ nhưng cách ly với nhau và với hệ điều hành chủ.

Các Thành Phần Chính của Docker:

- Docker Engine: Là công cụ chính của Docker, cung cấp khả năng tạo, triển khai và quản lý các container.
- Docker Images: Là mẫu không thay đổi của một container, chứa tất cả những gì cần thiết để chạy một ứng dụng (mã nguồn, runtime, thư viện, biến môi trường,...).
- Docker Containers: Là một instance của Docker image, một môi trường runtime có thể chạy độc lập.
- Docker registry: Là dịch vụ cung cấp không gian lưu trữ các Docker images và cho phép chia sẻ các images giữa các user.

<div align="center">
  <img width="600" src="./assets/images/architecture-of-docker.png" alt="Architecture of Docker">
</div>

<div align="center">
  <i><a href=https://www.geeksforgeeks.org/architecture-of-docker/>
         Architecture of Docker
        </a></i>
</div>

#### 1.1.2 Docker compose

Docker Compose là một công cụ dùng để định nghĩa và quản lý multi-container Docker applications. Với Docker Compose, có thể sử dụng một file YAML để định nghĩa các dịch vụ, mạng và volume của ứng dụng và sau đó dùng một lệnh đơn giản để tạo và chạy tất cả mọi thứ.

<div align="center">
  <img width="600" src="./assets/images/docker-compose.png" alt="Docker compose">
</div>

<div align="center">
  <i><a href=https://docs.docker.com/compose>
         Docker compose
    </a></i>
</div>

### 1.2 Output

#### 1.2.1 File docker và docker compose cho từng dịch vụ

File [docker](https://github.com/quangtuanitmo18/VDT-midterm-api/blob/main/Dockerfile.local) và [docker compose](https://github.com/quangtuanitmo18/VDT-midterm-api/blob/main/docker-compose.local.yml) dịch vụ api và database

File docker của dịch vụ api sử dụng:

- Multi-Stage Build: Nhằm tối ưu kích thước cuối cùng của image. Xây dựng đa giai đoạn cho phép sử dụng nhiều lệnh FROM trong Dockerfile. Mỗi lệnh FROM bắt đầu một stage mới của quá trình xây dựng.

  - Builder stage: Stage này cài đặt các phụ thuộc, sao chép các tệp cần thiết và xây dựng ứng dụng.
  - Start stage: Stage này tạo ra image cuối cùng, chỉ bao gồm các tệp cần thiết và các phụ thuộc thời gian chạy.

- Layer Caching: Docker lưu trữ kết quả của mỗi lệnh trong Dockerfile để tăng tốc quá trình xây dựng. Nếu một lớp không thay đổi, Docker sử dụng phiên bản đã lưu trong bộ nhớ đệm.

  - Sao chép Tối ưu: Bằng cách sao chép các tệp cần thiết khác và chạy các lệnh xây dựng trong các bước riêng biệt, Docker đảm bảo rằng các thay đổi trong mã nguồn không làm vô hiệu hóa các lớp đã lưu trữ cho các phụ thuộc, giúp tăng tốc quá trình xây dựng.

- Non-Root User: Tạo và chuyển sang người dùng không phải root (appuser) cải thiện bảo mật bằng cách đảm bảo ứng dụng không chạy với quyền root.

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

File docker-compose bao gồm triển khai dịch vụ api và db

- Dịch vụ api

  - container_name: Đặt tên cho container là vdt-midterm-api.
  - build:
    - context: Đặt đường dẫn ngữ cảnh xây dựng là thư mục hiện tại (./).
    - dockerfile: Chỉ định tệp Dockerfile là Dockerfile.local.
  - ports: Mở cổng 4000 trên máy host và ánh xạ tới cổng 4000 trong container.
  - restart: Cấu hình container tự động khởi động lại khi gặp sự cố (always).
  - image: Đặt tên cho image là vdt-midterm-api:v1.
  - env_file: Chỉ định tệp môi trường .env.development để cung cấp biến môi trường cho container.
  - networks: Tham gia mạng app-network.
  - depends_on: Đảm bảo rằng dịch vụ db được khởi động trước khi dịch vụ api khởi động.

- Dịch vụ db

  - container_name: Đặt tên cho container là vdt-midterm-db.
  - image: Sử dụng image MongoDB mới nhất (mongo:latest).
  - ports: Mở cổng 27017 trên máy host và ánh xạ tới cổng 27017 trong container.
  - volumes: Gắn volume mongodb_data từ máy host tới thư mục /data/db trong container để lưu trữ dữ liệu MongoDB.
  - environment: Thiết lập các biến môi trường cho MongoDB:
    - MONGO_INITDB_ROOT_USERNAME: Tên người dùng root (mongo_user).
    - MONGO_INITDB_ROOT_PASSWORD: Mật khẩu người dùng root (mongo_password).
  - restart: Cấu hình container tự động khởi động lại khi gặp sự cố (always).
  - networks: Tham gia mạng app-network.

- Mạng
  - app-network: [Định nghĩa mạng app-network](./assets/docs/docker-network.md) là mạng ngoài (external), tức là mạng này đã được tạo sẵn bên ngoài Docker Compose và sẽ được sử dụng lại.

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

**File [docker](https://github.com/quangtuanitmo18/VDT-midterm-web/blob/main/Dockerfile) và [docker compose](https://github.com/quangtuanitmo18/VDT-midterm-web/blob/main/docker-compose.local.yml) dịch vụ web**

Tuơng tự như trên, ngoài ra dịch vụ web sử dụng web server là nginx để triển khai dịch vụ.
Nginx là một máy chủ web mã nguồn mở hiệu suất cao. Hiện nay Nginx đã trở thành một trong những máy chủ web phổ biến nhất trên thế giới. Nginx không chỉ hoạt động như một máy chủ web mà còn có thể được sử dụng như một máy chủ proxy ngược (reverse proxy), cân bằng tải (load balancer), và cache HTTP.

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

#### 1.2.2 Output câu lệnh build và thông tin docker history của từng image

**Output câu lệnh build thông qua docker-compose**

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

**docker history của từng image**

<div align="center">
  <img width="600" src="./assets/images/docker-history-api.png" alt="Docker history api">
</div>

<div align="center">
  <i>Docker history of image vdt-midterm-api</i>
</div>
<br>

<div align="center">
  <img width="600" src="./assets/images/docker-history-web.png" alt="Docker history api">
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

## 2. CI/CD (1.5đ)

### 2.1 Mô tả

CI/CD là viết tắt của Continuous Integration và Continuous Delivery/Deployment, được xem như một quy trình kết hợp tự động hoá giúp đẩy nhanh tiến độ phát triển sản phẩm và đưa sản phẩm đến người dùng cuối cùng. CI/CD đã được áp dụng rộng rãi vào quy trình làm việc của các doanh nghiệp làm trong lĩnh vực IT, song hành cùng với DevOps và Agile.

**Continuous Integration (CI) - Tích hợp liên tục**

Continuous Integration là một phương pháp phát triển phần mềm trong đó các thay đổi mã nguồn được tích hợp vào nhánh chính thường xuyên. Quá trình này bao gồm:

- Tích hợp mã thường xuyên: Các lập trình viên thường xuyên đẩy (push) mã nguồn lên kho lưu trữ chung (repository).
- Tự động hóa xây dựng: Mỗi lần có thay đổi mã nguồn, một quy trình xây dựng tự động sẽ được kích hoạt để kiểm tra xem mã có thể được biên dịch và xây dựng mà không gặp lỗi.
- Kiểm thử tự động: Các bộ kiểm thử tự động (unit tests, integration tests) được thực hiện để đảm bảo mã mới không gây ra lỗi.

**Continuous Deployment/Continuous Delivery (CD) - Triển khai liên tục/Giao hàng liên tục**

So sánh giữa Continuous Deployment và Continuous Delivery

Quá trình này bao gồm:

- Tự động hóa triển khai: Sau khi mã đã vượt qua tất cả các kiểm thử tự động, nó sẽ được sẵn sàng để triển khai lên các môi trường.
- Giám sát và phản hồi: Hệ thống giám sát liên tục để phát hiện và xử lý các vấn đề sau khi triển khai.

So sánh giữa Continuous Deployment và Continuous Delivery

- Continuous Deployment: Tự động triển khai sau khi mã nguồn vượt qua tất cả các kiểm thử. Không cần sự can thiệp thủ công.
- Continuous Delivery: Mã nguồn sẵn sàng để triển khai sau khi vượt qua các kiểm thử, nhưng cần sự can thiệp thủ công để thực hiện triển khai cuối cùng.

<div align="center">
  <img width="600" src="./assets/images/ci-cd.png" alt="CI/CD">
</div>

<div align="center">
  <i>CI/CD</i>
</div>
<br>

Ưu điểm của CI/CD

- Tăng cường sự nhanh nhẹn: Đẩy nhanh quá trình phát triển và triển khai phần mềm.
- Giảm thiểu rủi ro: Tự động kiểm thử và triển khai giúp phát hiện và xử lý lỗi nhanh chóng.
- Tăng cường hợp tác: Các nhóm phát triển có thể làm việc hiệu quả hơn nhờ tích hợp liên tục và chia sẻ mã thường xuyên.
- Đảm bảo chất lượng: Kiểm thử tự động và triển khai liên tục đảm bảo mã nguồn có chất lượng cao hơn và ít lỗi hơn khi đến tay người dùng cuối.

Nhược điểm của CI/CD

- Thiết lập ban đầu phức tạp: Cần thời gian và công sức để thiết lập hệ thống CI/CD ban đầu.
- Chi phí: Có thể tốn kém trong việc thiết lập và duy trì hệ thống CI/CD, đặc biệt là với các dự án lớn.

### 2.2 Output

**Chuẩn bị tài nguyên**

[Dùng Vagrant để tạo máy ảo](./assets/docs/vagrant-vm-setup.md)

Để triển khai CICD Pipeline trong bài này cần chuẩn bị các tài nguyên như sau:
Các server dưới đây chạy trên Ubuntu focal 20.04

- Server 1: **_CI/CD QA server (cicd-qa-server)_**: Memory: 3 GB, Processors: 1 – IP: `192.168.64.140`
  - Port `8080` - Jenkins server
  - Port `9000` - Sonarqube server
- Server 2: **_Gitlab server (gitlab-server)_**: Memory: 3 GB, Processors: 1 – IP: `192.168.64.141`
- Server 3: **_App server 1 (app-server-1)_**: Memory: 1 GB, Processors: 1 – IP: `192.168.64.142`
- Server 4: **_Database server (database-server)_**: Memory: 1 GB, Processors: 1, Disk: 20 GB – IP: `192.168.64.143`
- Server 5: **_App server 2 (app-server-2)_**: Memory: 1 GB, Processors: 1 – IP: `192.168.64.144`
- Server 6: **_Load balancing server (lb-server)_**: Memory: 1 GB, Processors: 1 – IP: `192.168.64.145`
- Server 7: Docker registry: sử dụng **_Docker Hub_**

**Setup ban đầu lên các server**

- [Setup gitlab server](./assets/docs/gitlab-server-setup.md)

- [Setup jenkins server](./assets/docs/jenkins-server-setup.md)

- [Setup sonarqube server](./assets/docs/sonarqube-server-setup.md)

- [Setup database server](./assets/docs/database-server-setup.md)

- [Setup Nginx server làm load balancer](./assets/docs/nginx-server-setup.md)

- [Setup Docker Hub](./assets/docs/dockerhub-setup.md)

- [Cài đặt docker và docker-compose](./assets/docs/docker-setup.md)

#### 2.2.1 Cấu hình Pipeline CI/CD

Để có thể chạy pipeline CI/CD đám ứng nhu cầu:

- Tự động chạy khi tạo PR vào branch main
- Tự động chạy push commit lên một branch

Dưới đây là config của webhook trên Gitlab repo `VDT-midterm-api` và config của pipeline `pipeline-vdt-midterm-api` trên Jekins của dịch vụ `api`. Đối với dịch vụ `web` cài đặt tương tự.

**Config webhook trên repo Gitlab**
Trong dự án chọn `Settings -> Webhooks` cấu hình như sau:
`URL: http://<account trên jenkins>:<token account jenkins>@<địa chỉ jenkins>/project/<tên project trên jenkins>`

Webhook của của `VDT-midterm-api` sẽ có URL là: `http://jenkins-admin:1197fee3ac6455760068658062a4cbda6a@192.168.64.140:8080/project/pipeline-vdt-midterm-api`

<div align="center">
  <img width="800" src="./assets/images/gitlab-webhook-1.png" alt="Network settting">
</div>
<div align="center">
  <img width="800" src="./assets/images/gitlab-webhook-api.png" alt="Network settting">
</div>

**Config pipeline trên Jenkins**
`Dashboard -> pipeline-vdt-midterm-api -> configuration ` tại `Build Triggers` chọn như dưới đây

<div align="center">
  <img width="800" src="./assets/images/jenkins-config-pipeline-2.png" alt="">
</div>
<br>

Tại `Branches To Build` ở đây chọn là main và release vậy là khi merge request hoặc push từ 2 nhánh này Jenkins mới chạy. Tránh trường hợp cứ push và tạo merge request ở 1 nhánh bất kì thì pipeline đều chạy.

<div align="center">
  <img width="800" src="./assets/images/jenkins-config-pipeline-5.png" alt="">
</div>
<br>

Với các cài đặt trigger ở repo Gitlab và ở pipeline Jenkins như trên thì đã đảm bảo được yêu cầu. Chi tiết các bước cài đặt tại mục `2.2.1`
<br>

#### 2.2.2 Pipeline CI/CD trên Jenkins

Các credentials tạo trên Jenkins cho pipeline

- `gitlab-api-token`: token được tạo vởi user có quyền admin trên Gitlab
- `gitlab-credential`: tài khoản có quyền admin trên Gitlab
- `sonarqube-token`: token được tạo vởi user có quyền admin trên Sonarqube
- `sonar-host-url`: url truy cập vào Sonarqube server `192.168.64.140:9000`
- `vdt-midterm-web-project-key`: project key của project `vdt-midterm-web` trên Sonarqube
- `vdt-midterm-api-project-key`: project key của project `vdt-midterm-api` trên Sonarqube
- `jenkins-ssh-key`: private ssh key được tạo để ssh đến `app-server-1` và `app-server-2`
- `dockerhub-credential`: tài khoản dockerhub
- `telegram-token`: token được tạo bởi `BotFather` trên Telegram
- `telegram-chatId`: chat ID của bot chat trên Telegram
- `ip-app-server-1`: `192.168.64.142`
- `ip-app-server-2`: `192.168.64.144`
- `vdt-midterm-api-env`: file env cho môi trường prod của `web` service
- `vdt-midterm-web-env`: file env cho môi trường prod của `api` service

<div align="center">
  <img width="1000" src="./assets/images/jenkins-credentials.png" alt="">
</div>
<div align="center">
  <i>Jenkins credentials</i>
</div>
<br>

**_Dưới đây là pipeline CI/CD của service `api`, đổi với service `web` cũng sẽ tương tự_**

- `def deployToServer(serverAddress)`: Hàm này triển khai ứng dụng đến một máy chủ cụ thể thông qua SSH và Docker

  - `deploying`: Chuỗi lệnh bash để xoá container Docker hiện có, kéo hình ảnh Docker mới từ Docker Hub và chạy container mới
  - `sshagent`: Sử dụng khóa SSH để kết nối tới máy chủ từ xa và chạy tập lệnh triển khai

- `def sendTelegramMessage(token, chatId, message)`: Hàm này giúp gửi tin nhắn đến Telegram

  - `sh`: Chạy lệnh curl để gửi tin nhắn qua API của Telegram

- `pipeline`

  - `agent any`: Chỉ định rằng pipeline này có thể chạy trên bất kỳ agent nào của Jenkins
  - `environment`: Khai báo các biến môi trường cần thiết cho pipeline
  - `stages`: Bao gồm các bước cụ thể trong quá trình pipeline

    - Stage `Prepare pipeline`: Gửi tin nhắn Telegram thông báo bắt đầu build
    - Stage `Checkout source`: Sao chép mã nguồn vào thư mục dự án, thay đổi quyền sở hữu và quyền truy cập
    - Stage `Test with SonarQube`: Chạy kiểm tra mã nguồn với SonarQube để phân tích chất lượng mã nguồn
    - Stage `Check lint and prettier`: Cài đặt các phụ thuộc npm và chạy kiểm tra linting và định dạng mã với Prettier
    - Stage `Unit test with Jest`: Đọc tệp môi trường và chạy kiểm tra unit test với Jest
    - Stage `Build and push image`
      - Điều kiện kiểm tra nếu commit có tag. Nếu đúng, hỏi người dùng có muốn build và đẩy Docker Image lên Docker Hub không
      - Nếu người dùng chọn "Yes", build và đẩy Docker Image lên Docker Hub.
    - Stage `Deploy`

      - Điều kiện kiểm tra nếu commit có tag. Nếu đúng, hỏi người dùng có muốn triển khai không
      - Nếu người dùng chọn "Yes", triển khai ứng dụng tới các máy chủ đã chỉ định

  - `post`: Gửi thông báo đến Telegram dựa trên kết quả của pipeline:
    - `success`: Gửi tin nhắn thành công
    - `failure`: Gửi tin nhắn thất bại
    - `aborted`: Gửi tin nhắn khi pipeline bị hủy

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

File `.env.production` của service `api` ([link repo](https://github.com/quangtuanitmo18/VDT-midterm-api))

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

File `.env` của service `web` ([link repo](https://github.com/quangtuanitmo18/VDT-midterm-web))

```shell
VITE_API_URL="http://192.168.64.145/api"
```

#### 2.2.3 Các hình ảnh demo

**Các hình ảnh demo cho pipeline** `pipeline-vdt-midterm-api`

Khi push hoặc tạo merge request vào nhánh `main` hoặc `release`, pipeline sẽ bỏ qua stage `Build and push image` và `Deploy` do chưa có tag.

<div align="center">
  <img width="1000" src="./assets/images/jenkins-pipeline-api-9.png" alt="">
</div>

Tiến hành tạo tag trên nhánh main của repo `VDT-midterm-api`, lúc này đã có thể thực hiện được stage `Build and push image` và `Deploy` thông qua 1 bước manual để xác nhận có muốn thực hiện 2 stage này không (Continuous Delivery)

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

Image được đẩy lên Docker hub

<div align="center">
  <img width="1000" src="./assets/images/jenkins-pipeline-api-4.png" alt="">
</div>
<br>

Sonarqube phân tích code

<div align="center">
  <img width="1000" src="./assets/images/jenkins-pipeline-api-5.png" alt="">
</div>
<br>

Docker image được pull về và chạy lên trên `app-server-1` và `app-server-2`

<div align="center">
  <img width="1000" src="./assets/images/jenkins-pipeline-api-6.png" alt="">
</div>
<div align="center">
  <img width="1000" src="./assets/images/jenkins-pipeline-api-7.png" alt="">
</div>
<br>

Nhận thông báo bên Telegram

<div align="center">
  <img width="1000" src="./assets/images/jenkins-pipeline-api-8.png" alt="">
</div>
<br>

**Các hình ảnh demo cho pipeline** `pipeline-vdt-midterm-web`

Khi push hoặc tạo merge request vào nhánh `main` hoặc `release`, pipeline sẽ bỏ qua stage `Build and push image` và `Deploy` do chưa có tag.

<div align="center">
  <img width="1000" src="./assets/images/jenkins-pipeline-web-1.png" alt="">
</div>

Tiến hành tạo tag trên nhánh main của repo `VDT-midterm-web`, lúc này đã có thể thực hiện được stage `Build and push image` và `Deploy` thông qua 1 bước manual để xác nhận có muốn thực hiện 2 stage này không (Continuous Delivery)

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
Image được đẩy lên Docker hub

<div align="center">
  <img width="1000" src="./assets/images/jenkins-pipeline-web-6.png" alt="">
</div>
<br>

Sonarqube phân tích code

<div align="center">
  <img width="1000" src="./assets/images/jenkins-pipeline-web-7.png" alt="">
</div>
<br>

Docker image được pull về và chạy lên trên `app-server-1` và `app-server-2`

<div align="center">
  <img width="1000" src="./assets/images/jenkins-pipeline-web-8.png" alt="">
</div>
<br>
<div align="center">
  <img width="1000" src="./assets/images/jenkins-pipeline-web-9.png" alt="">
</div>
<br>

Nhận thông báo bên Telegram

<div align="center">
  <img width="1000" src="./assets/images/jenkins-pipeline-web-10.png" alt="">
</div>
<br>

**Kết quả hiển thị trên browser**

Truy cập vào địa chỉ ip `192.168.64.145` là của `lb-server`

<div align="center">
  <img width="1000" src="./assets/images/web-test-1.png" alt="">
</div>
<br>

Vậy là sau khi tạo tag trên repo `VDT-midterm-api` và `VDT-midterm-api` làm cho pipeline `pipeline-vdt-midterm-api` và `pipeline-vdt-midterm-web` được thực thi thì code mới đã được triển khai lên `app-server-1` và `app-server-2`.

<div align="center">
  <img width="1000" src="./assets/images/lb-schema.png" alt="Create token">
</div>
<div align="center">
<i>
Load balancing schema
</i>
</div>
<br>

## 3. Automation

### 3.1 Mô tả

Automation (Tự động hóa) là quá trình sử dụng công nghệ để thực hiện các tác vụ hoặc quy trình một cách tự động, giảm thiểu sự can thiệp của con người. Automation giúp tăng hiệu suất, giảm thiểu sai sót và tiết kiệm thời gian trong các quy trình làm việc.

Ansible là một công cụ mã nguồn mở được sử dụng cho tự động hóa việc triển khai, quản lý và cấu hình hệ thống và ứng dụng. Ansible sử dụng ngôn ngữ YAML để mô tả cấu hình và các nhiệm vụ, và hoạt động dựa trên mô hình tình trạng mong muốn (desired state). Ansible không yêu cầu cài đặt các phần mềm hoặc `agent` trên các nút mục tiêu, và hoạt động qua `SSH` để tương tác với các máy chủ.

Các tính năng chính của Ansible bao gồm:

- Declarative Configuration Management: Ansible cho phép mô tả trạng thái mong muốn của hệ thống trong các tệp YAML, và nó sẽ đảm bảo rằng hệ thống tuân theo trạng thái đó.

- Idempotent Operations: Các mô-đun của Ansible thực hiện các thao tác idempotent, có nghĩa là có thể chạy chúng nhiều lần mà không gây ảnh hưởng đến trạng thái của hệ thống.

- Infrastructure as Code (IaC): Ansible cho phép quản lý cơ sở hạ tầng của mình dưới dạng mã nguồn, giúp tạo ra môi trường cơ sở hạ tầng có khả năng tái tạo và linh hoạt.

- Modularity và Reusability: Ansible cho phép chia nhỏ các tác vụ thành các phần tử nhỏ hơn gọi là roles và playbook, giúp tái sử dụng và duy trì dễ dàng.

- Community and Ecosystem: Ansible có một cộng đồng rộng lớn và phong phú, cung cấp nhiều roles và module sẵn có để có thể sử dụng và mở rộng.

### 3.2 Output

Các bước cài đặt Ansible
[Repo VDT-midterm-ansible](https://github.com/quangtuanitmo18/VDT-midterm-ansible)
Cài Ansible lên server `cicd-qa-server: 192:168.64.140`

Thư mục chứa ansible playbook dùng để triển khai các dịch vụ, trong thư mục này gồm có:

- File `inventory.ini`: Chứa danh sách các hosts và được chia thành các groups để triển khai
- File `playbook.yml`: Định nghĩa các hành động và quy trình để thực hiện trên các máy chủ mục tiêu thông qua roles
- Thư mục roles chứa các role:
  - `docker`: Cài đặt docker và docker-compose
  - `web`: Triển khai dịch vụ web bằng cách pull docker image đã có ở trên docker hub từ bước CI/CD và chạy lên
  - `api`: Triển khai dịch vụ api bằng cách pull docker image đã có ở trên docker hub từ bước CI/CD và chạy lên
  - `database`: Triển khai dịch vụ database
  - `nginx`: Cài đặt Nginx server
  - `loadbalancing`: Triển khai load balancing

#### 3.2.1 Các hình ảnh demo

Logs khi chạy playbook

<div align="center">
  <img width="1000" src="./assets/images/ansible-log-1.png" alt="">
</div>
<div align="center">
  <img width="1000" src="./assets/images/ansible-log-2.png" alt="">
</div>
<div align="center">
  <img width="1000" src="./assets/images/ansible-log-3.png" alt="">
</div>
