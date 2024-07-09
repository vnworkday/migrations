create sequence tenant_id_seq as int;

create table tenant
(
    id                        int          not null default nextval('tenant_id_seq'),
    public_id                 varchar(32)  not null default nanoid(),
    name                      varchar(256) not null,
    state                     int          not null default 1, -- 1: provisioning, 2: active, 3: inactive
    domain                    varchar(256) not null,           -- e.g., 'example.vnworkday.vn'
    timezone                  varchar(64)  not null,           -- e.g., 'America/New_York'
    production_type           int          not null default 1, -- 1: production, 2: root, 3: internal
    subscription_type         int          not null default 1, -- 1: basic, 2: standard, 3: premium
    self_registration_enabled boolean      not null default false,
    created_at                timestamptz  not null default now(),
    updated_at                timestamptz  not null default now(),
    constraint pk_tenant_id primary key (id)
);

create unique index uid_tenant_public_id on tenant(public_id);
create unique index uid_tenant_domain on tenant(domain);

insert into tenant (public_id, name, state, domain, timezone, production_type, subscription_type,
                    self_registration_enabled)
values (nanoid(), 'VN Workday Master', 2, 'root.vnworkday.vn', 'Asia/Ho_Chi_Minh', 2, 3, false);