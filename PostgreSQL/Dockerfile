FROM postgres:11.4-alpine

COPY pg_hba.conf /var/lib/pgsql/11/data/

RUN chmod postgres:postgres /var/lib/pgsql/11/data/pg_hba.conf

EXPOSE 5432