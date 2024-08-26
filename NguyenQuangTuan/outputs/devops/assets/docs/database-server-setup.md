## Setup database MongoDB (database-server: 192.168.64.143)

Chạy database MongoDB qua file docker-compose.yml

```shell
version: "3.8"
services:
  mongodb:
    container_name: vdt-midterm-db
    image: mongo:latest
    ports:
      - "27017:27017"
    volumes:
      - mongodb_data:/data/db
    environment:
      MONGO_INITDB_ROOT_USERNAME: mongo_user
      MONGO_INITDB_ROOT_PASSWORD: mongo_password
    restart: always
volumes:
  mongodb_data:
```

Với cài đặt biến môi trường `MONGO_INITDB_ROOT_USERNAME=mongo_user`, `MONGO_INITDB_ROOT_PASSWORD=mongo_password` và port được map từ container ra bên ngoài database-server `27017` thì uri đẻ kết nối tới Mongo là:
`mongodb://mongo_user:mongo_password@192.168.64.143:27017`

Trong Database sẽ có 2 instance là `vdt-midterm` và `vdt-midterm-test`.
`vdt-midterm` sẽ là instance dùng cho môi trường `prod`, còn `vdt-midterm-test` sẽ phục vụ cho các môi trường như `staging`, `dev` hoặc để làm db cho việc chạy test.

<div align="center">
  <img src="../images/mongo-instances.png" alt="MongoDb">
</div>
