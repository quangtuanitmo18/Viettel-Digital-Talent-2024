### Setup Nginx làm load balancer (lb-server: 192.168.64.145)

NGINX là một phần mềm mã nguồn mở phổ biến, chủ yếu được sử dụng như một máy chủ web, máy chủ proxy ngược (reverse proxy), và cân bằng tải (load balancer). Được phát triển bởi Igor Sysoev và ra mắt lần đầu vào năm 2004, NGINX nổi tiếng với hiệu suất cao, khả năng xử lý nhiều kết nối đồng thời, và tính ổn định. Dưới đây là một số thông tin chi tiết về NGINX và vai trò của nó như một load balancer:

- Chức năng chính của NGINX
  - Web server: NGINX có thể phục vụ các tệp tĩnh (static files) như HTML, CSS, JavaScript và hình ảnh một cách hiệu quả.
  - Reverse Proxy: NGINX có thể đóng vai trò là một proxy ngược, chuyển tiếp các yêu cầu từ người dùng đến các máy chủ, giúp bảo vệ và ẩn máy chủ khỏi người dùng cuối.
  - Load Balancer: NGINX có thể phân phối tải truy cập đến nhiều máy chủ để tối ưu hóa tài nguyên và cải thiện hiệu suất ứng dụng.
  - Security: NGINX cung cấp nhiều tính năng bảo mật như chặn IP, giới hạn tốc độ, và SSL/TLS termination.
  - Caching: NGINX hỗ trợ caching để tăng tốc độ phản hồi của các ứng dụng web.

<div align="center">
  <img width="600" src="../images/nginx.png" alt="Nginx">
</div>
<br>

**NGINX như một Load Balancer**

Load balancer là một thành phần quan trọng trong các hệ thống phân tán, giúp phân phối lưu lượng truy cập đồng đều đến các máy chủ để đảm bảo hiệu suất và tính sẵn sàng của ứng dụng. NGINX có thể thực hiện cân bằng tải thông qua các phương pháp sau:

Các phương pháp cân bằng tải:

- Round Robin: Phương pháp mặc định, phân phối các yêu cầu theo thứ tự tuần tự đến từng máy chủ.
- Least Connections: Phân phối yêu cầu đến máy chủ có ít kết nối nhất hiện tại, giúp giảm tải cho các máy chủ bận rộn.
- IP Hash: Sử dụng hash của địa chỉ IP của khách hàng để xác định máy chủ, giúp duy trì phiên làm việc của người dùng.
- Weight: Định nghĩa trọng số cho mỗi máy chủ, máy chủ có trọng số cao hơn sẽ nhận nhiều yêu cầu hơn.

#### Cài đặt và cấu hình nginx làm load balancer

Cài Nginx thông qua lệnh `sudo apt install nginx`.
Thay đổi nội dung của file `nginx.conf` trong đường dẫn `/etc/nginx/`

**_Upstream_**

Các khối upstream web và upstream api định nghĩa các nhóm máy chủ để cân bằng tải. Các khối này xác định các máy chủ sẽ xử lý các yêu cầu cho từng dịch vụ.

- upstream web có hai máy chủ: `192.168.64.142:80` và `192.168.64.144:80`.
- upstream api có hai máy chủ: `192.168.64.142:4000` và `192.168.64.144:4000`.

**_Server_**

Định nghĩa một máy chủ lắng nghe trên cổng 80.

- location `/`:

  - Xử lý tất cả các yêu cầu đến URL gốc.
  - proxy_pass `http://web;` chuyển tiếp các yêu cầu đến nhóm upstream web.

- location `/api`:

  - Xử lý tất cả các yêu cầu đến URL bắt đầu bằng `/api`.
  - rewrite `^/api/(.\*)$ /$1 break;`:
    - Quy tắc rewrite này loại bỏ `/api` khỏi URI yêu cầu trước khi chuyển nó tới các máy chủ .
    - Ví dụ, một yêu cầu đến `/api/users/list` sẽ được rewrite thành `/users/list` trước khi được chuyển tiếp.
  - proxy_pass `http://api;` chuyển tiếp các yêu cầu đến nhóm upstream api.

```shell
events {

}
http {
    # Upstream server configuration for web service
    upstream web {
        server 192.168.64.142:80;
        server 192.168.64.144:80;
    }
    # Upstream server configuration for api service
    upstream api {
        server 192.168.64.142:4000;
        server 192.168.64.144:4000;
    }
    server {
        listen 80;
        # Confiduration for web
        location / {
            proxy_pass http://web;
        }
        # Configuration for api
        location /api {
            rewrite ^/api/(.*)$ /$1 break;
            proxy_pass http://api;
        }
    }
}
```

Với cấu hình Nginx như trên thì khi truy cập đến `192.168.64.145` sẽ được điều hướng đến `192.168.64.142` hoặc `192.168.64.144`. Tương tự khi truy cập vào `192.168.64.145/api` sẽ được điều hướng tới `192.168.64.142:4000` hoặc `192.168.64.144:4000`

<br>
<div align="center">
  <img width="1000" src="../images/lb-schema.png" alt="Create token">
</div>
<div align="center">
<i>
Load balancing schema
</i>
</div>
<br>
