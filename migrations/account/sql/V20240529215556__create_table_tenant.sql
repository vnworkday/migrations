create table tenant
(
    id        serial       not null,
    public_id varchar(16)  not null,
    name      varchar(255) not null,
    state     int          not null default 1, -- 0: inactive, 1: active
    constraint pk_tenant_id primary key (id),
    constraint uidx_tenant_public_id unique (public_id),
    constraint uidx_tenant_name unique (name),
    constraint ck_tenant_state check (state in (0, 1))
);