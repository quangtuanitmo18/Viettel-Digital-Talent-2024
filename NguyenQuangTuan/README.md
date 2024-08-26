# Bài tập lớn giữa kỳ chương trình VDT 2024 lĩnh vực Cloud

## Phát triển một 3-tier web application đơn giản (3đ)

Yêu cầu:

- Phát triển web application có các chức năng sau (0.5đ):

  - Hiển thị danh sách sinh viên tham gia chương trình VDT2024 dưới dạng bảng với các thông tin sau: Họ và tên, Giới tính, trường đang theo học.
  - Cho phép xem chi tiết/thêm/xóa/cập nhật thông tin sinh viên.

- Thiết kế hệ thống với ba dịch vụ (1đ):
  - <b>web</b>: Giao diện web, tuỳ chọn ngôn ngữ, framework.
  - <b>api</b>: RESTful API viết bằng ngôn ngữ lập trình tùy chọn, có đầy đủ các chức năng: list, get, create, update, delete.
  - <b>db</b>: Database SQL hoặc NoSQL lưu trữ thông tin sinh viên.
- Viết unit tests cho các chức năng APIs, mỗi API tối thiếu 1 testcase (0.5đ).
- Maintain source code của api và web ở 2 repo khác nhau, mỗi feature là 1 Pull Request (1đ).

Output:

- Hình ảnh thể hiện kết quả đã đạt được
- Mã nguồn của từng dịch vụ (link github)

<b>Output</b>: [Output 3-tier web application](./outputs/3-tier-web/README.md)

## Triển khai web application sử dụng các DevOps tools & practices (5đ)

#### 1. Containerization (2đ)

Yêu cầu:

- Viết Dockerfile để ở từng repo để đóng gói các dịch vụ trên thành các container image (1đ)
- Yêu cầu image đảm bảo tối ưu thời gian build và kích thước chiếm dụng, khuyến khích sử dụng các thủ thuật build image đã được giới thiệu (layer-caching, optimized RUN instructions, multi-stage build, etc.) (1đ)

Output:

- File Dockerfile cho từng dịch vụ
- Output câu lệnh build và thông tin docker history của từng image

#### 2. Continuous Integration (1.5đ)

Yêu cầu:

- Tự động chạy unit test khi tạo PR vào branch main (0.5đ)
- Tự động chạy unit test khi push commit lên một branch (1đ)

Output:

- File setup công cụ CI
- Output log của luồng CI
- Các hình ảnh demo khác

#### 3. Automation (1.5đ)

Yêu cầu:

- Viết ansible playbooks để triển khai các image docker của các dịch vụ web, api, db, mỗi dịch vụ 1 role (0.5đ).
- Trong từng role cho phép tuỳ biến cấu hình của các dịch vụ thông qua các variables (0.5đ).
- Cho phép triển khai các dịch vụ trên các host khác nhau thông qua file inventory (0.5đ).

Output:

- Link github source code của ansible playbooks

<b>Output</b>: [Output triển khai web application sử dụng các DevOps tools & practices ](./outputs/devops/README.md)

## Nghiên cứu sâu về một vấn đề, khái niệm trong các chủ đề đã được học (2đ)

Yêu cầu:

- Viết bất gì về bất cứ gì trong các chủ đề đã được học

Output:

- File báo cáo trong PR lên repo chung

<b>Output</b>: [DevSecOps](./outputs/research-topic/README.md)
