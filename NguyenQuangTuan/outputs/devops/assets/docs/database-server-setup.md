## Setup MongoDB database (database-server: 192.168.64.143)

Run MongoDB database using the docker-compose.yml file

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

With the environment variables set as `MONGO_INITDB_ROOT_USERNAME=mongo_user`, `MONGO_INITDB_ROOT_PASSWORD=mongo_password` and the port mapped from the container to the outside of the database-server `27017`, the URI to connect to Mongo is:
`mongodb://mongo_user:mongo_password@192.168.64.143:27017`

In the Database, there will be 2 instances: `vdt-midterm` and `vdt-midterm-test`.
`vdt-midterm` will be the instance used for the `prod` environment, while `vdt-midterm-test` will serve environments such as `staging`, `dev`, or as a db for running tests.

<div align="center">
  <img src="../images/mongo-instances.png" alt="MongoDb">
</div>
