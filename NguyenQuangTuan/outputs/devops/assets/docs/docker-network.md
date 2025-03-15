## Setup network to connect api, web, and db services

Run the command `docker network create app-network` to create a network named **app-network**.

Check existing networks with `docker network ls`.

<div align="center">
  <img width="600" src="../images/docker-network-ls.png" alt="Container networking">
</div>

<div align="center">
  <i>Container networking</i>
</div>

After running 3 containers for the 3 services web, api, and db, inspect the network to see that the 3 services are in **app-network**.

<div align="center">
  <img width="600" src="../images/docker-network-inspect.png" alt="Inspect network">
</div>

<div align="center">
  <i>Inspect network</i>
</div>
