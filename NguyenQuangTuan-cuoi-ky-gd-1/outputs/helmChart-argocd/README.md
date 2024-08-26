# K8S Helm Chart

## 1. Mô tả

### 1.1 Helm và Helm-chart

**Helm** là một công cụ quản lý package dành cho Kubernetes, được thiết kế để giúp người dùng dễ dàng triển khai, quản lý và chia sẻ các ứng dụng Kubernetes. Tương tự như các trình quản lý package khác như apt cho Debian/Ubuntu hoặc yum cho RedHat/CentOS, Helm giúp bạn cài đặt và cập nhật các ứng dụng trên Kubernetes một cách dễ dàng và nhất quán.

**Helm Chart** là một tập hợp các file được tổ chức theo cấu trúc thư mục xác định, chứa tất cả thông tin cần thiết để triển khai một ứng dụng hoặc dịch vụ trên Kubernetes. Một Chart bao gồm:

- `Templates`: Các file mẫu YAML định nghĩa các tài nguyên Kubernetes như Pod, Service, Deployment, v.v. Các file này có thể sử dụng các biến để tạo ra cấu hình linh hoạt.
- `Values`: Các file YAML chứa các giá trị mặc định cho các biến trong templates. Bạn có thể cung cấp các giá trị riêng khi triển khai Chart để tùy chỉnh cấu hình.
- `Chart.yaml`: File metadata chứa thông tin về Chart như tên, phiên bản, mô tả, và các thông tin liên quan khác.
- `Charts`: Thư mục chứa các Chart phụ thuộc (dependencies).
- `README.md`: File mô tả chi tiết về Chart, cách sử dụng và các tùy chọn cấu hình.

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

**Argo CD** là một công cụ mã nguồn mở dành cho Continuous Deployment (CD) được xây dựng để triển khai và quản lý các ứng dụng Kubernetes một cách tự động. Nó là một phần của bộ công cụ Argo, được thiết kế đặc biệt để quản lý các ứng dụng Kubernetes bằng cách sử dụng mô hình GitOps.

**Gitops** GitOps là một phương pháp triển khai ứng dụng và quản lý cơ sở hạ tầng bằng cách sử dụng Git. Trong mô hình GitOps, các cấu hình và trạng thái mong muốn của hệ thống được lưu trữ trong các kho lưu trữ Git. Các thay đổi được thực hiện thông qua việc cập nhật các kho lưu trữ này, và sau đó các công cụ tự động hóa như Argo CD sẽ áp dụng các thay đổi đó lên môi trường Kubernetes.

<div align="center">
  <img width="1000" src="./assets/images/arrgocd-1.png" alt="">
</div>

## 2. Output

Các tài nguyên từ bài giữa kỳ đã triển khai

- Server 1: **_CI/CD QA server (cicd-qa-server)_**: Memory: 3 GB, Processors: 1 – IP: `192.168.64.140`
  - Port `8080` - Jenkins server
  - Port `9000` - Sonarqube server
- Server 2: **_Gitlab server (gitlab-server)_**: Memory: 3 GB, Processors: 1 – IP: `192.168.64.141`
- Server 3: **_App server 1 (app-server-1)_**: Memory: 1 GB, Processors: 1 – IP: `192.168.64.142`
- Server 4: **_Database server (database-server)_**: Memory: 1 GB, Processors: 1 – IP: `192.168.64.143`
- Server 5: **_App server 2 (app-server-2)_**: Memory: 1 GB, Processors: 1 – IP: `192.168.64.144`
- Server 6: **_Load balancing server (lb-server)_**: Memory: 1 GB, Processors: 1 – IP: `192.168.64.145`
- Server 7: Docker registry: sử dụng **_Docker Hub_**

Trong bài cuối kỳ chuẩn bị thêm các tài nguyên:

- Server 8: **_k8s master server (k8s-master-server)_**: Memory: 2 GB, Processors: 1 – IP: `192.168.64.148`
- Server 9: **_k8s worker server (k8s-worker-server)_**: Memory: 2 GB, Processors: 2 – IP: `192.168.64.149`

<br>

**_Trước tiên_** cần cài Storage cho K8s dùng NFS để sau này lưu dữ liệu của DB lên đó (Link tài liệu cài đặt [link1](https://rudimartinsen.com/2024/01/09/nfs-csi-driver-kubernetes/), [link2](https://viblo.asia/p/k8s-phan-3-cai-dat-storage-cho-k8s-dung-nfs-RnB5pAw7KPG))

Tìm hiều thêm về Volume, PersistentVolume, PersistentVolumeClaim, StorageClass, Provisioner trên k8s [tại đây](https://viblo.asia/p/k8s-basic-kubernetes-storage-qPoL7X6mVvk)

Về reclaim policy có 2 loại là delete và retain, đó là cấu hình chính sách xử lý các phân vùng lưu trữ khi xóa PVC.

- `delete`: Khi xóa một Persistent Volume Claim (PVC) trên K8S thì hệ thống cũng tự động xóa Persistent Volume (PV) tương ứng và đồng thời hỗ trợ xóa luôn phân vùng lưu trên thiết bị lưu trữ mà gán với PV đó
- `retain`: Khi xóa PVC trên K8S thì phân vùng lữu trữ trên thiết bị lưu trữ sẽ không tự động bị xóa đi.

Trong bài lab này cài NFS-server lên `database-server: 192.168.64.143`, cài đặt NFS-client lên worker node `k8s-worker-server: 192.168.64.148` và cài đặt NFS storage class lên cluster (tại phần cài k8s đã cài kubectl lên server `cicd-qa-server: 192.168.64.140` và cấu hình tới cluster rồi cho nên từ giờ mọi cài đặt lên cluster sẽ được thực hiện qua server này)

Trong bài cài 3 pod với reclaim policy là `retain`

### 2.1 Helm-chart

#### Database

**Database được expose qua service ClusterIP**

Đầu tiên dựng DB lên trước bằng helm, chi tiết các file xem tại [VDT-config-helm-db](https://github.com/quangtuanitmo18/VDT-config-helm-db)

Lần lượt apply config, env, headless service, statesulset và service của Database lên cluster

<div align="center">
  <img width="1000" src="./assets/images/helm-db-2.png" alt="">
</div>
<br>

Mỗi Pod đều được gán 1 PVC riêng
Trong bài lab này PVC triển khai theo reclaim policy là `retain`

<div align="center">
  <img width="1000" src="./assets/images/helm-db-3.png" alt="">
</div>
<br>

Qua NFS-server `database-server: 192.168.64.143` check thì đã thấy các PV được tạo

<div align="center">
  <img width="1000" src="./assets/images/helm-db-4.png" alt="">
</div>
<br>

Các Pod của Statefulset không thể được tạo hay xóa cùng lúc. Nó sẽ được tạo tuần tự và cần triển khai database theo `statefulset` chứ không phải `deployment` do data cần triển khai theo dạng relication

<div align="center">
  <img width="1000" src="./assets/images/data-replication-1.png" alt="">
</div>
<br>

Khi đó pod có cả quyền read/write sẽ được gọi là `Primary` (vdt-db-0) còn pod còn quyền read thôi sẽ được gọi là `Secondary` (vdt-db-1, vdt-db-2), Ngày xưa thuật ngữ này được gọi là `Master-Slave`

<div align="center">
  <img width="1000" src="./assets/images/data-replication-2.png" alt="">
</div>
với Statefulset là các Pod của nó không sử dụng chung phần lưu trữ. Mỗi Pod sẽ có phân vùng lưu trữ khác nhau dù dữ liệu chúng lưu trữ là như nhau (cùng được replicate từ bản chính ra). Mỗi Pod sẽ có phân vùng lưu trữ riêng của nó để lưu trữ dữ liệu. Dữ liệu của mỗi Pod được liên tục đồng bộ để đảm bảo dữ liệu lưu trên mỗi Pod là luôn giống hệt nhau.

Sau khi thực hiện các bước trên đã dựng được Database stateful lên rồi, tuy nhiên việc sao chép và đồng bộ dữ liệu cần thực hiện thêm 1 bước initiate
`vdt-db-0.vdt-db.vdt-final.svc.cluster.local:27017` là link để kết nối tới Database trong cluster (`Pod Name.Service Name.Namespace.Domain(svc.cluster.local).Port`)

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

**API được expose qua service NodePort**

Triển khai Api bằng deployment, chi tiết helm-chart để tại thư mục `helm` trong repo `VDT-midterm-api` [tại đây](https://github.com/quangtuanitmo18/VDT-midterm-api/tree/main/helm).

File `values.yaml` để sang 1 repo config [VDT-config-helm-api](https://github.com/quangtuanitmo18/VDT-config-helm-api)

#### WEB

**WEB được expose qua service NodePort**

Triển khai Web bằng deployment, chi tiết helm-chart để tại thư mục `helm` trong repo `VDT-midterm-web` [tại đây](https://github.com/quangtuanitmo18/VDT-midterm-web/tree/main/helm).

File `values.yaml` để sang 1 repo config [VDT-config-helm-api](https://github.com/quangtuanitmo18/VDT-config-helm-web)

### 2.1 ArgoCD

#### Cài đặt

Cài ArgoCD bằng lệnh sau

```shell
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Sau khi đã cài thành công cần cấu hình service thành NortPort để truy cập được từ bên ngoài (ở đây là port 32538)
`kubectl patch svc -n argocd argocd-server --patch '{"spec": {"type": "NodePort"}}'`

<div align="center">
  <img width="1000" src="./assets/images/argocd-2.png" alt="">
</div>
<br>

Lấy mật khẩu của argoCD
`kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`

<div align="center">
  <img width="1000" src="./assets/images/argocd-3.png" alt="">
</div>
<div align="center">
  <img width="1000" src="./assets/images/argocd-5.png" alt="">
</div>
<br>

#### Triển khai các service web và api service lên K8S Cluster bằng multiple sources của ArgoCD

Thực hiện theo như hướng dẫn [Multiple sources for an application](https://argo-cd.readthedocs.io/en/release-2.7/user-guide/multiple_sources/#helm-value-files-from-external-git-repository)

Triển khai multisource cho một ứng dụng bằng Argo CD là một chiến lược mà trong đó một ứng dụng có thể được định nghĩa bởi nhiều nguồn khác nhau, như các kho lưu trữ Git hoặc các thư mục khác nhau trong một kho lưu trữ. Điều này cho phép một ứng dụng được quản lý, cấu hình và triển khai từ nhiều nguồn một cách linh hoạt và hiệu quả.
Một vài issues về multiple resources trên ArgoCD ([argoproj-3988](https://github.com/argoproj/argo-cd/issues/3988),[argoproj-6280](https://github.com/argoproj/argo-cd/issues/6280) )

Do bài được phát triển từ bài giữa kỳ (bài giữa kỳ host Gitlab trên local để lưu repositories) nền cần thực hiện tạo 2 repo là `VDT-config-helm-api` và `VDT-config-helm-web` để lưu trữ các file values trên gitlab

<div align="center">
  <img width="1000" src="./assets/images/repo-config-api.png" alt="">
</div>
<div align="center">
  <img width="1000" src="./assets/images/repo-config-web.png" alt="">
</div>
<br>

File `argocd-vdt-api-app.yaml` và `argocd-vdt-web-app.yaml` cho việc triển khai Api và Web bằng multiple sources. 2 repo `VDT-midterm-api` và `VDT-midterm-web` là 2 repo lưu code trên gitlab từ bài giữa kỳ.

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

Sau khi apply 2 file trên, truy cập vào argoCD được kết quả

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

Check các pod trên k8s

<div align="center">
  <img width="1000" src="./assets/images/argocd-9.png" alt="">
</div>

Hình ảnh truy cập vào web và api từ trình duyệt. Web được expose nodeport `30002` còn api được expose nodeport `30003`

<div align="center">
  <img width="1000" src="./assets/images/web-1.png" alt="">
</div>
<div align="center">
  <img width="1000" src="./assets/images/api-1.png" alt="">
</div>
<br>
