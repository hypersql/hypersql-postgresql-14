# HyperSQL-PostgreSQL14 for CentOS 7

Usage
-----
- Build docker image
  ```
  docker build -t hypersql-pg14:centos .
  ```
- Start HyperSQL-PG14 instance
  ```
  docker run --privileged --name hypersql-pg14 hypersql-pg14:centos
  ```
  - Set password for superuser
    ```
    docker run --privileged -e POSTGRES_PASSWORD=[password] --name hypersql-pg14 hypersql-pg14:centos
    ```
  - Set customized config
    ```
    docker run --privileged -v [absolute/path/to/your/config]:/hypersql/settings/postgresql.custom.conf
               --name hypersql-pg14 hypersql-pg14:centos
    ```
  - Disable data checksums
    ```
    docker run --privileged -e POSTGRES_ENABLE_DATA_CHECKSUMS="n"
               --name hypersql-pg14 hypersql-pg14:centos
    ```
  - Change host auth method
    ```
    docker run --privileged -e POSTGRES_HOST_AUTH_METHOD="[available auth-method]"
               --name hypersql-pg14 hypersql-pg14:centos
    ```