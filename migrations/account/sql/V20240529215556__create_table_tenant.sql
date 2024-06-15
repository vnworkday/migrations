create sequence tenant_id_seq as int;

create table tenant
(
    id        int          not null default nextval('tenant_id_seq'),
    public_id varchar(32)  not null,
    name      varchar(256) not null,
    state     int          not null default 1, -- 1: active, 2: inactive
    constraint pk_tenant_id primary key (id),
    constraint uid_tenant_public_id unique (public_id),
    constraint uid_tenant_name unique (name)
);

insert into tenant (public_id, name, state)
values ('jUBJX6iCzF7CppVejN20L', 'VN Workday Master', 1);

-- create trigger to prevent delete tenant with public_id = 'jUBJX6iCzF7CppVejN20L'
create function prevent_delete_tenant()
    returns trigger
    language plpgsql
as
$$
begin
    if old.public_id = 'jUBJX6iCzF7CppVejN20L' then
        raise exception 'Cannot delete master tenant';
    end if;
    return old;
end
$$;

create trigger prevent_delete_tenant
    before delete
    on tenant
    for each row
    execute function prevent_delete_tenant();