# Final Project for VDT 2024 Cloud Program

## Deploy Kubernetes (1 point)

Requirement (choose 1 of 2):

- Deploy Kubernetes using minikube on 1 node: 0.5 points

- Deploy Kubernetes using kubeadm or kubespray on 1 master node VM + 1 worker node VM: 1 point

Output:

- Installation documentation
- Logs of system check commands such as: kubectl get nodes -o wide

<b>Output</b>: [Kubernetes](./outputs/k8s/README.md)

## Deploy web application using DevOps tools & practices (5 points)

#### 1. K8S Helm Chart (1.5 points)

Requirement 1:

- Install ArgoCD on Kubernetes Cluster, expose ArgoCD via NodePort
- If using the lab cluster on Viettel Cloud, install Loadbalancer on Bastion Node using docker-compose, expose ArgoCD port to the public environment through one of the ports assigned to each student

Output 1:

- Manifests files used to deploy ArgoCD on K8S Cluster
- Config file, docker-compose.yaml used to deploy ArgoCD loadbalancer on Bastion Node (if using the lab cluster on Viettel Cloud)
- Screenshot of ArgoCD system interface when accessed via browser

Requirement 2:

- Write 2 Helm Charts for web Deployment and api Deployment, place them in a separate folder in the web repo and api repo
- Create 2 Config Repos for web and api, containing values.yaml files with necessary configs to run web and api on k8s using Helm Chart
- Use ArgoCD's multiple sources feature to deploy web and api services on K8S Cluster as per ArgoCD's guide, expose these services as NodePort
- If using the lab cluster on Viettel Cloud, install Loadbalancer on Bastion Node using docker-compose, expose 2 ports of Web to the public environment through one of the ports assigned to each student

Output 2:

- Helm Charts used to deploy web Deployment and api Deployment on K8S Cluster
- values.yaml files in 2 config repos of web service and api service
- ArgoCD Application manifest
- Config file, docker-compose.yaml used to deploy ArgoCD loadbalancer on Bastion Node (if using the lab cluster on Viettel Cloud)
- Screenshot of ArgoCD system interface on browser
- Screenshot of browser interface when accessing Web URL, API URL

<b>Output</b>: [Helm-Chart and ArgoCD](./outputs/helmChart-argocd/README.md)

#### 2. Continuous Delivery (1.5 points)

Requirement:

- Write 2 CD pipelines for 2 repos web and api, when a new tag is created on one of these repos, the corresponding deploy pipeline of that repo performs the following tasks:

  - Build docker image with image tag as the tag name created on gitlab and push the built docker image to Docker Hub
  - Update Image version value in values.yaml file in config repo and push the change to config repo

- Configure ArgoCD to automatically redeploy web Deployment and api Deployment when there is a change in config repo.

Output:

- Setup files for 2 CD pipelines
- Output log of 2 CD pipelines when creating a new tag on web repo and api repo
- Screenshot of app deployed by argoCD, screenshot of diff when argoCD detects changes in config repo similar to the image below
- Other demo images such as event list in the app

<b>Output</b>: [CD](./outputs/cd/README.md)

#### 3. Monitoring (1.5 points)

Requirement:

- Expose metrics of web service and api service on an http path.
- Deploy Prometheus on Kubernetes Cluster using Prometheus Operator, expose it as NodePort
- Expose Prometheus as NodePort
- If using the lab cluster on Viettel Cloud, create a load balancer with backend as NodePort Service of Prometheus, to expose Prometheus UI to Public Internet
- Use Prometheus Operator's Service Monitor to monitor Web Deployment and API Deployment

Output:

- Setup files to deploy Prometheus on Kubernetes Cluster
- Screenshot when accessing Prometheus UI via browser
- Screenshot of target list of Web Deployment and API Deployment monitored by Prometheus

<b>Output</b>: [Monitoring](./outputs/monitoring/README.md)

#### 4. Logging (1.5 points)

Requirement:

- Use Kubernetes DaemonSet to deploy fluentd or fluentbit on kubernetes to push logs of Web Deployment and API Deployment to a centralized ElasticSearch cluster with index prefix in the format student_name_abbreviation_phone_number: Example: conghm_012345678

Centralized ES cluster information:

- Username: elastic
- Password: iRsUoyhqW-CyyGdwk6V\_
- Elastic Search URL: https://116.103.226.146:9200
- Kibana URL: http://116.103.226.146:5601/login?next=%2Fapp%2Fdiscover#/
- Configure logging for web service and api service, ensure that when an http request is sent to web service or api service, at least 1 log contains the following information:
  - Request Path (e.g., /api1/1, /api2/3 ..)
  - HTTP Method (e.g., GET, PUT, POST…)
  - Response Code: 302, 200, 202, 201…

Output:

- Screenshot of Kibana search results for logs of Web Service and API Service by url path

<b>Output</b>: Not completed

## Security (1.5 points)

Requirement 1 (1 point):

- Set up HAProxy Loadbalancer on a separate VM (if using a student's own lab cluster) or on Bastion Node (if using Viettel Cloud lab cluster) with TCP mode, open 2 ports web_port and api_port on LB pointing to 2 NodePorts of Web Deployment and API Deployment on K8S Cluster. (0.5)
- Use one of the solutions Ingress, or haproxy sidecar container for deployments, ensure that accesses to web_port and api_port use https (0.5)
- Allow students to use self-signed cert for the assignment

Output 1:

- Configuration file of HAProxy Loadbalancer for web port and api port
- Ingress configuration file or deployment configuration file after adding HAProxy sidecar container to Deployment
- Result of accessing web port and api port from browser via https or using curl.

Requirement 2 (1 point):

- Ensure that some URLs of api service require authentication using one of the methods cookie, basic auth, token auth, otherwise return HTTP response code 403. (0.5)
- Implement authorization for 2 types of users on API:
  - If the user has role user, accessing GET request returns code 200, while accessing POST/DELETE returns 403
  - If the user has role admin, accessing GET request returns code 200, while accessing POST/DELETE returns 2xx

Output 2:

- Document presenting the solution used for authentication/authorization for the services
- Result of HTTP Response when using curl or postman to call URLs with and without authentication information
- Result of HTTP Response when using curl or postman to call URLs with GET/POST/DELETE methods using authentication information of users with roles user and admin

Requirement 3 (1 point):

- Use one of the solutions to ratelimit the Endpoint of api Service, so that if there are more than 10 requests in 1 minute sent to the Endpoint of api service, subsequent requests are returned with HTTP Response 409

<b>Output</b>: [Security](./outputs/security/README.md)
