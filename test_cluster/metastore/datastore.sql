create table jobs
(
    job_id                  bigserial primary key,
    job_name                 varchar(1000) not null,
    data_line_name           varchar(500),
    target_db                varchar(100),
    target_table             varchar(1000),
    table_partitioning_types varchar(1000),
    data_refreshed_at        varchar(100)
);

ALTER TABLE public.jobs owner TO sparkapp;
GRANT SELECT,INSERT ON TABLE public.jobs TO sparkapp;

create table job_runs
(
    job_run_id    bigserial primary key,
    job_id        bigint                      NOT NULL REFERENCES jobs (job_id),
    start_time          timestamp   not null,
    end_time            timestamp   not null,
    status              varchar(20) not null,
    table_refresh       varchar(100),
    import_count        bigint default 0,
    delta_read_end_time varchar(5000)
);

ALTER TABLE public.job_runs owner TO sparkapp;
GRANT SELECT,INSERT ON TABLE public.job_runs TO sparkapp;

create table partition_refreshes
(
    partition_refresh_id bigserial primary key,
    job_id               bigint                      NOT NULL REFERENCES jobs (job_id),
    job_run_id           bigint                      NOT NULL REFERENCES job_runs (job_run_id),
    partition            varchar(1000),
    logging_time         timestamp not null,
    status               varchar(20),
    version              bigint
);

ALTER TABLE public.partition_refreshes owner TO sparkapp;
GRANT SELECT,INSERT ON TABLE public.partition_refreshes TO sparkapp;
