# K8S Helm Chart

## 1. Description

### 1.1 Helm and Helm-chart

**Helm** is a package manager for Kubernetes, designed to help users easily deploy, manage, and share Kubernetes applications. Similar to other package managers like apt for Debian/Ubuntu or yum for RedHat/CentOS, Helm helps you install and update applications on Kubernetes easily and consistently.

**Helm Chart** is a collection of files organized in a specific directory structure, containing all the information needed to deploy an application or service on Kubernetes. A Chart includes:

- `Templates`: YAML template files defining Kubernetes resources such as Pod, Service, Deployment, etc. These files can use variables to create flexible configurations.
- `Values`: YAML files containing default values for variables in the templates. You can provide custom values when deploying the Chart to customize the configuration.
- `Chart.yaml`: Metadata file containing information about the Chart such as name, version, description, and other related information.
- `Charts`: Directory containing dependent Charts.
- `README.md`: File describing the Chart in detail, how to use it, and configuration options.

<div align="center">
  <img width="1000" src="./assets/images/helm-chart-1.png" alt="">
</div>

<div align="center">
  <i><a href=https://www.freecodecamp.org/news/what-is-a-helm-chart-tutorial-for-kubernetes-beginners/>
         Helm-chart
</a></i>
</div>
<br>

### 1.2 ArgoCD

**Argo CD** is an open-source tool for Continuous Deployment (CD) built to deploy and manage Kubernetes applications automatically. It is part of the Argo toolset, specifically designed to manage Kubernetes applications using the GitOps model.

**GitOps** is a method of deploying applications and managing infrastructure using Git. In the GitOps model, the desired configurations and states of the system are stored in Git repositories. Changes are made by updating these repositories, and then automation tools like Argo CD apply those changes to the Kubernetes environment.

<div align="center">
  <img width="1000" src="./assets/images/arrgocd-1.png" alt="">
</div>

## 2. Output

Resources from the midterm project have been deployed

- Server 1: **_CI/CD QA server (cicd-qa-server)_**: Memory: 3 GB, Processors: 1 – IP: `192.168.64.140`
  - Port `8080` - Jenkins server
  - Port `9000` - Sonarqube server
- Server 2: **_Gitlab server (gitlab-server)_**: Memory: 3 GB, Processors: 1 – IP: `192.168.64.141`
- Server 3: **_App server 1 (app-server-1)_**: Memory: 1 GB, Processors: 1 – IP: `192.168.64.142`
- Server 4: **_Database server (database-server)_**: Memory: 1 GB, Processors: 1 – IP: `192.168.64.143`
- Server 5: **_App server 2 (app-server-2)_**: Memory: 1 GB, Processors: 1 – IP: `192.168.64.144`
- Server 6: **_Load balancing server (lb-server)_**: Memory: 1 GB, Processors: 1 – IP: `192.168.64.145`
- Server 7: Docker registry: using **_Docker Hub_**

Additional resources prepared for the final project:

- Server 8: **_k8s master server (k8s-master-server)_**: Memory: 2 GB, Processors: 1 – IP: `192.168.64.148`
- Server 9: **_k8s worker server (k8s-worker-server)_**: Memory: 2 GB, Processors: 2 – IP: `192.168.64.149`

<br>

**_First_** install Storage for K8s using NFS to later store DB data on it (Installation guide links [link1](https://rudimartinsen.com/2024/01/09/nfs-csi-driver-kubernetes/), [link2](https://viblo.asia/p/k8s-phan-3-cai-dat-storage-cho-k8s-dung-nfs-RnB5pAw7KPG))

Learn more about Volume, PersistentVolume, PersistentVolumeClaim, StorageClass, Provisioner on k8s [here](https://viblo.asia/p/k8s-basic-kubernetes-storage-qPoL7X6mVvk)

Regarding reclaim policy, there are two types: delete and retain, which are configurations for handling storage partitions when deleting PVC.

- `delete`: When deleting a Persistent Volume Claim (PVC) on K8S, the system also automatically deletes the corresponding Persistent Volume (PV) and supports deleting the storage partition associated with that PV.
- `retain`: When deleting PVC on K8S, the storage partition on the storage device will not be automatically deleted.

In this lab, install NFS-server on `database-server: 192.168.64.143`, install NFS-client on worker node `k8s-worker-server: 192.168.64.148`, and install NFS storage class on the cluster (at the k8s installation step, kubectl was installed on the server `cicd-qa-server: 192.168.64.140` and configured to the cluster, so from now on all installations on the cluster will be done through this server).

In this lab, install 3 pods with reclaim policy set to `retain`.

### 2.1 Helm-chart

#### Database

**Database is exposed via ClusterIP service**

First, set up the DB using helm, detailed files can be found at [VDT-config-helm-db](https://github.com/quangtuanitmo18/VDT-config-helm-db)

Sequentially apply config, env, headless service, statefulset, and service of the Database to the cluster.

<div align="center">
  <img width="1000" src="./assets/images/helm-db-2.png" alt="">
</div>
<br>

Each Pod is assigned its own PVC
In this lab, PVC is deployed with the reclaim policy set to `retain`

<div align="center">
  <img width="1000" src="./assets/images/helm-db-3.png" alt="">
</div>
<br>

Checking on the NFS-server `database-server: 192.168.64.143`, the PVs have been created

<div align="center">
  <img width="1000" src="./assets/images/helm-db-4.png" alt="">
</div>
<br>

Pods of a Statefulset cannot be created or deleted simultaneously. They are created sequentially, and the database needs to be deployed as a `statefulset` rather than a `deployment` because the data needs to be deployed in a replication manner.

<div align="center">
  <img width="1000" src="./assets/images/data-replication-1.png" alt="">
</div>
<br>

In this case, the pod with both read/write permissions is called `Primary` (vdt-db-0), while the pods with read-only permissions are called `Secondary` (vdt-db-1, vdt-db-2). Previously, these terms were known as `Master-Slave`.

<div align="center">
  <img width="1000" src="./assets/images/data-replication-2.png" alt="">
</div>
With Statefulset, its Pods do not share storage. Each Pod has a different storage partition, even though the data they store is the same (replicated from the primary). Each Pod has its own storage partition to store data. The data of each Pod is continuously synchronized to ensure that the data stored on each Pod is always identical.

After performing the above steps, the Database stateful has been set up, but data replication and synchronization require an additional initiation step.
`vdt-db-0.vdt-db.vdt-final.svc.cluster.local:27017` is the link to connect to the Database within the cluster (`Pod Name.Service Name.Namespace.Domain(svc.cluster.local).Port`)

```shell
rs.initiate({
  _id: "rs0",
  members: [
    { _id: 0, host: "vdt-db-0.vdt-db.vdt-final.svc.cluster.local:27017" },
    { _id: 1, host: " vdt-db-1.vdt-db.vdt-final.svc.cluster.local:27017" },
    { _id: 2, host: " vdt-db-2.vdt-db.vdt-final.svc.cluster.local:27017" }
  ]
})
```

<div align="center">
  <img width="1000" src="./assets/images/data-replication-3.png" alt="">
</div>
<br>

#### API

**API is exposed via NodePort service**

Deploy the API using deployment, detailed helm-chart is located in the `helm` folder in the `VDT-midterm-api` repo [here](https://github.com/quangtuanitmo18/VDT-midterm-api/tree/main/helm).

The `values.yaml` file is placed in a config repo [VDT-config-helm-api](https://github.com/quangtuanitmo18/VDT-config-helm-api)

#### WEB

**WEB is exposed via NodePort service**

Deploy the Web using deployment, detailed helm-chart is located in the `helm` folder in the `VDT-midterm-web` repo [here](https://github.com/quangtuanitmo18/VDT-midterm-web/tree/main/helm).

The `values.yaml` file is placed in a config repo [VDT-config-helm-web](https://github.com/quangtuanitmo18/VDT-config-helm-web)

### 2.1 ArgoCD

#### Installation

Install ArgoCD using the following commands

```shell
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

After successful installation, configure the service to NodePort to access it from outside (here it is port 32538)
`kubectl patch svc -n argocd argocd-server --patch '{"spec": {"type": "NodePort"}}'`

<div align="center">
  <img width="1000" src="./assets/images/argocd-2.png" alt="">
</div>
<br>

Get the ArgoCD password
`kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`

<div align="center">
  <img width="1000" src="./assets/images/argocd-3.png" alt="">
</div>
<div align="center">
  <img width="1000" src="./assets/images/argocd-5.png" alt="">
</div>
<br>

#### Deploy web and api services to the K8S Cluster using ArgoCD's multiple sources

Follow the guide [Multiple sources for an application](https://argo-cd.readthedocs.io/en/release-2.7/user-guide/multiple_sources/#helm-value-files-from-external-git-repository)

Deploying multisource for an application using Argo CD is a strategy where an application can be defined by multiple sources, such as different Git repositories or different directories within a repository. This allows an application to be managed, configured, and deployed from multiple sources flexibly and efficiently.
Some issues about multiple resources on ArgoCD ([argoproj-3988](https://github.com/argoproj/argo-cd/issues/3988),[argoproj-6280](https://github.com/argoproj/argo-cd/issues/6280))

Since the project is developed from the midterm project (the midterm project hosts Gitlab locally to store repositories), it is necessary to create two repos `VDT-config-helm-api` and `VDT-config-helm-web` to store the values files on Gitlab.

<div align="center">
  <img width="1000" src="./assets/images/repo-config-api.png" alt="">
</div>
<div align="center">
  <img width="1000" src="./assets/images/repo-config-web.png" alt="">
</div>
<br>

The `argocd-vdt-api-app.yaml` and `argocd-vdt-web-app.yaml` files for deploying Api and Web using multiple sources. The two repos `VDT-midterm-api` and `VDT-midterm-web` are the two code repos on Gitlab from the midterm project.

```shell
#argocd-vdt-api-app.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: vdt-api-app
spec:
  project: default
  destination:
    server: https://kubernetes.default.svc
    namespace: vdt-final
  sources:
    - repoURL: 'http://tuanmaintainer:Anhtuan123@192.168.64.141/tuanmaintainer/vdt-midterm-api.git'
      targetRevision: main
      path: helm
      helm:
        valueFiles:
          - $values/values.yaml
    - repoURL: 'http://tuanmaintainer:Anhtuan123@192.168.64.141/tuanmaintainer/vdt-config-helm-api.git'
      targetRevision: main
      ref: values
  syncPolicy:
    automated: {}
```

```shell
# argocd-vdt-api-web.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: vdt-web-app
spec:
  project: default
  destination:
    server: https://kubernetes.default.svc
    namespace: vdt-final
  sources:
    - repoURL: 'http://tuanmaintainer:Anhtuan123@192.168.64.141/tuanmaintainer/vdt-midterm-web.git'
      targetRevision: main
      path: helm
      helm:
        valueFiles:
          - $values/values.yaml
    - repoURL: 'http://tuanmaintainer:Anhtuan123@192.168.64.141/tuanmaintainer/vdt-config-helm-web.git'
      targetRevision: main
      ref: values
  syncPolicy:
    automated: {}
```

After applying the above two files, access ArgoCD to get the result

<div align="center">
  <img width="1000" src="./assets/images/argocd-6.png" alt="">
</div>
<div align="center">
  <img width="1000" src="./assets/images/argocd-7.png" alt="">
</div>
<div align="center">
  <img width="1000" src="./assets/images/argocd-8.png" alt="">
</div>
<br>

Check the pods on k8s

<div align="center">
  <img width="1000" src="./assets/images/argocd-9.png" alt="">
</div>

Images of accessing web and api from the browser. Web is exposed on nodeport `30002` and api is exposed on nodeport `30003`.

<div align="center">
  <img width="1000" src="./assets/images/web-1.png" alt="">
</div>
<div align="center">
  <img width="1000" src="./assets/images/api-1.png" alt="">
</div>
<br>
