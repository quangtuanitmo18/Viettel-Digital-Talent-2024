#!/bin/bash

# Cài đặt Java Development Kit (JDK)
apt update
apt install -y default-jdk

# Cài đặt Elasticsearch
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb [trusted=yes] https://mirror.yandex.ru/mirrors/elastic/8/ stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list

apt update
apt install -y elasticsearch

# Cấu hình Elasticsearch
echo "network.host: 0.0.0.0" >> /etc/elasticsearch/elasticsearch.yml

# Khởi động Elasticsearch
systemctl enable elasticsearch
systemctl start elasticsearch

# Cài đặt Logstash
echo "deb [trusted=yes] https://mirror.yandex.ru/mirrors/elastic/8/ stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list

apt update
apt install -y logstash

# Cài đặt Kibana
echo "deb [trusted=yes] https://mirror.yandex.ru/mirrors/elastic/8/ stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list

apt update
apt install -y kibana

# Cấu hình Kibana để cho phép truy cập từ tất cả các nguồn
echo "server.host: 0.0.0.0" >> /etc/kibana/kibana.yml

# Khởi động Kibana
systemctl enable kibana
systemctl start kibana

# Reset mật khẩu elastic search và tạo token cho kibana
elastic_password=$(echo "y" | /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic | grep -o "New value: .*" | cut -d ' ' -f 3-)
kibana_token=$(/usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana)

# Di chuyển và mở verification code
cd /usr/share/kibana && verification_code=$(bin/kibana-verification-code)

# Hiển thị thông tin đăng nhập
echo "Thông tin đăng nhập:"
echo "-------------------"
echo "Elasticsearch:"
echo "   Tài khoản: elastic"
echo "   Mật khẩu: $elastic_password"
echo ""
echo "Kibana:"
echo "   Token: $kibana_token"
echo ""
echo "Mã xác minh Kibana:"
echo "$verification_code"
