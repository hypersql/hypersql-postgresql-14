# HyperSQL-PostgreSQL14 for Redhat ubi8

Usage
-----
- Build docker image
  ```
  docker build -t hypersql-pg14:redhat .
  ```
- Start HyperSQL-PG14 instance
  ```
  docker run --privileged --name redhat hypersql-pg14:redhat
  ```
  - Set password for superuser
    ```
    docker run --privileged -e POSTGRES_PASSWORD=[password] --name redhat hypersql-pg14:redhat
    ```
  - Set customized config
    ```
    docker run --privileged -v [absolute/path/to/your/config]:/hypersql/settings/postgresql.custom.conf
               --name redhat hypersql-pg14:redhat
    ```
  - Disable data checksums
    ```
    docker run --privileged -e POSTGRES_ENABLE_DATA_CHECKSUMS="n"
               --name redhat hypersql-pg14:redhat
    ```
  - Change host auth method
    ```
    docker run --privileged -e POSTGRES_HOST_AUTH_METHOD="[available auth-method]"
               --name redhat hypersql-pg14:redhat
    ```
  - Change log level of PostgreSQL server
    ```
    docker run --privileged -e POSTGRES_DEBUG_LEVEL=[1-5, default=1]
               --name redhat hypersql-pg14:redhat
    ```
