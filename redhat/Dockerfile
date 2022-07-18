FROM redhat/ubi8:latest

# Argument settings                                                              
                                                                                 
# Install necessary packages                                                     
# Add in alphabetical order                                                      
RUN yum -y update && yum clean all \                                             
    && yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm \
    && yum repolist \                                                            
    && yum -y install epel-release \
    && yum -y install \
           gcc \
           gcc-c++ \
           gettext \
           git \
           libxslt \
           libicu \
           make \
           openssl \
           openssl-devel \
           perl \
           perl-libs \
           python3 \
           pwgen \
           readline \
           systemd-sysv \
           sudo \
           tar \
           tcl \
           which \
           zlib \
           zlib-devel \
           lz4 \
     && yum clean all \
# Download and install PostgreSQL RPM
     && export PG_MAJOR=14 \
     && export PG_VERSION=14.3 \
     && export PG_RPM_BASE_URL=https://yum.postgresql.org/${PG_MAJOR}/redhat/rhel-8-x86_64/ \
     && rpm -ivh ${PG_RPM_BASE_URL}/postgresql${PG_MAJOR}-libs-${PG_VERSION}-1PGDG.rhel8.x86_64.rpm \
     && rpm -ivh ${PG_RPM_BASE_URL}/postgresql${PG_MAJOR}-${PG_VERSION}-1PGDG.rhel8.x86_64.rpm \
     && rpm -ivh ${PG_RPM_BASE_URL}/postgresql${PG_MAJOR}-server-${PG_VERSION}-1PGDG.rhel8.x86_64.rpm \
     && rpm -ivh ${PG_RPM_BASE_URL}/postgresql${PG_MAJOR}-contrib-${PG_VERSION}-1PGDG.rhel8.x86_64.rpm

# TODO: Add outside extensions here

# User settings
RUN groupadd hypersql -g 1008 \
    && useradd hypersql -u 1008 -g hypersql -c 'HyperSQL Database' -d /hypersql \
    && passwd -d hypersql \
    && echo "hypersql  ALL=(ALL)  NOPASSWD: ALL" >> /etc/sudoers \
    && mkdir -p /hypersql/settings \
                /hypersql/pg/14/data \
                /hypersql/pg/14/log/pg_log \
                /hypersql/pg/14/pg_wall \
                /hypersql/pg/14/archive \
                /var/run/hypersql \
    && chown -R hypersql:hypersql /hypersql /var/run/hypersql

COPY ./settings/* /hypersql/settings/ 
RUN chown hypersql:hypersql /hypersql/settings/bashrc.hypersql \
                            /hypersql/settings/bashrc.tmp \
                            /hypersql/settings/entrypoint.sh \
                            /hypersql/settings/postgresql.init.conf \
    && cat /hypersql/settings/bashrc.tmp >> /hypersql/.bashrc \
    && rm /hypersql/settings/bashrc.tmp

EXPOSE 5432

USER hypersql

ENV POSTGRES_PASSWORD=""
ENV POSTGRES_ENABLE_DATA_CHECKSUMS="y"
ENV POSTGRES_HOST_AUTH_METHOD="scram-sha-256"
ENV POSTGRES_DEBUG_LEVEL=1
ENV SLEEP_ON_FAILURE="n"

ENTRYPOINT ["bash", "-i", "/hypersql/settings/entrypoint.sh"]
