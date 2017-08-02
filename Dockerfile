FROM postgres
COPY src/main/resources/schema-postgresql.sql /tmp/schema-postgresql.sql
COPY src/main/resources/data-postgresql.sql /tmp/data-postgresql.sql

RUN docker-entrypoint.sh -e POSTGRES_PASSWORD=pass postgres

RUN psql -f /tmp/schema-postgresql.sql -U postgres
RUN psql -f /tmp/data-postgresql.sql -U postgres