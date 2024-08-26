## Setup gitLab trên server (gitlab-server: 192.168.64.141)

Cần lựa chọn phiên bản gitlab phù hợp với hệ điều hành hiện tại (ubuntu/focal 20.04)

<div align="center">
  <img width="600" src="../images/gitlab-ce-14.4.1-versions.png" alt="gitlab-ce_14.4.1">
</div>

<div align="center">
  <i>gitlab-ce_14.4.1</i>
</div>
<br>
<div align="center">
  <img width="600" src="../images/gitlab-ce-14.4.1-focal.png" alt="gitlab-ce_14.4.1-focal">
</div>

<div align="center">
  <i>gitlab-ce_14.4.1 focal</i>
</div>
<br>

### Cài đặt Gitlab CE

Cài đặt [gitlab-ce_14.1.8-ce.0_arm64.deb](https://packages.gitlab.com/gitlab/gitlab-ce/packages/ubuntu/focal/gitlab-ce_14.1.8-ce.0_arm64.deb) cần thực hiện các bước sau:

Chạy lệnh cài đặt kho lưu trữ `curl -s https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash`

Chạy lệnh để cài đặt gitlab `sudo apt-get install gitlab-ce=14.1.8-ce.0`

<div align="center">
  <img width="600" src="../images/gitlab-installed.png" alt="Successfully installed gitlab">
</div>

<div align="center">
  <i>Successfully installed gitlab
</i>
</div>
<br>

Tiếp đến cần truy cập vào file config của gitlab `vi /etc/gitlab/gitlab.rb` và cập nhật lại external_url thành ip hiện tại.

<div align="center">
  <img width="600" src="../images/gitlab-external-url.png" alt="Update external url of gitlab">
</div>

<div align="center">
  <i>Update external url of gitlab</i>
</div>
<br>

sau đó chạy lệnh `gitlab-ctl reconfigure` để cập nhật lại config.

<div align="center">
  <img width="600" src="../images/gitlab-1.png" alt="">
</div>

<div align="center">
  <i>Gitlab</i>
</div>
<br>

Để đăng nhập được vào gitlab cần lấy mật khẩu của user root
Chạy lệnh `cat /etc/gitlab/initial_root_password` để lấy mật khẩu user root

<div align="center">
  <img width="600" src="../images/gitlab-password-user-root.png" alt="password user root">
</div>

<div align="center">
  <i>Root password</i>
</div>
<br>

Thực hiện đổi mật khẩu của user root và tạo thêm 2 user là: `tuan-maintainer` và `tuan-developer`.
Tạo 2 repo là: `VDT-midterm-api` và `VDT-midterm-web` sau đó thêm 2 user phía trên vào.

<div align="center">
  <img width="600" src="../images/gitlab-add-users-to-repo-api.png" alt="">
</div>

<div align="center">
  <i>Add user to repository VDT-midterm-api</i>
</div>
<br>

<div align="center">
  <img width="600" src="../images/gitlab-add-users-to-repo-web.png" alt="">
</div>

<div align="center">
  <i>Add user to repository VDT-midterm-web</i>
</div>
<br>

Trên cả 2 repo tạo các nhánh `main`, `release`, `develop`. Khi phát triển 1 feature mới sẽ thực hiện checkout ra và tạo merge request vào nhánh develop. Từ develop sẽ được merge vào release rồi sau đó đến main. Các tag sẽ được tạo từ nhánh main để đánh dấu các phiên bản triển khai.

<div align="center">
  <img width="600" src="../images/gitlab-branches.png" alt="">
</div>

<div align="center">
  <i>branches</i>
</div>
<br>

Tiếp theo thiết lập protected branch để đảm bảo chỉ có maintainer mới có quyền push và merge MR trên nhánh `main` và `release`.

<div align="center">
  <img width="600" src="../images/gitlab-protected-branch.png" alt="">
</div>

<div align="center">
  <i>Protected branch</i>
</div>
<br>

### Tạo access token của user trên Gitlab server

Để phục vụ cho việc kết nối gitlab với jenkins và sonarqube cần tạo 1 access token. Access token phải được tạo từ user có quyền admin trên gitlab.

<div align="center">
  <img width="800" src="../images/gitlab-personal-at-create.png" alt="Personal gitlab access token">
</div>
<div align="center">
  <img width="800" src="../images/gitlab-personal-at.png" alt="Personal gitlab access token">
</div>

<div align="center">
  <i>Personal gitlab access token</i>
</div>
<br>

### Tạo webhook để trigger đến pipeline bên Jenkins

Cài đặt network cho phép request từ web hooks và system hooks đến local network
Trong cài đặt `Admin Area -> Settings -> Network -> Outbound requests`

<div align="center">
  <img width="800" src="../images/gitlab-network-setting.png" alt="Network settting">
</div>
<div align="center">
  <i>Network setting</i>
</div>
<br>

Các bước thực hiện với repo `VDT-midterm-api`, đổi với `VDT-midterm-web` thực hiện tương tự.

Trong dự án nhấn chọn `Settings -> Webhooks` cấu hình như sau:
`URL: http://<account trên jenkins>:<token account jenkins>@<địa chỉ jenkins>/project/<tên project trên jenkins>`

Webhook của của `VDT-midterm-api` sẽ có URL là: `http://jenkins-admin:1197fee3ac6455760068658062a4cbda6a@192.168.64.140:8080/project/pipeline-vdt-midterm-api`

<div align="center">
  <img width="800" src="../images/gitlab-webhook-1.png" alt="Network settting">
</div>
<br>
<div align="center">
  <img width="800" src="../images/gitlab-webhook-api.png" alt="Network settting">
</div>

Thực hiện các bước tương tự với repo `VDT-midterm-web`
Webhook của của `VDT-midterm-web` sẽ có URL là: `http://jenkins-admin:1197fee3ac6455760068658062a4cbda6a@192.168.64.140:8080/project/pipeline-vdt-midterm-web`

<div align="center">
  <img width="800" src="../images/gitlab-webhook-web.png" alt="Network settting">
</div>
