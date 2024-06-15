# Account Database Schema (`account`)

## Table: `tenant`

### Schema

|    Name     | Data Type | Required? |  Default   | Description                                                        |
|:-----------:|:---------:|:---------:|:----------:|--------------------------------------------------------------------|
|    `id`     |   `int`   |    Yes    |     No     | Auto-incremented primary key, intended for internal usage          |
| `public_id` | `varchar(32)` |    Yes    |     No     | Public identifier in form of `nanoid`, intended for external usage |
|   `name`    | `varchar(256)` |    Yes    |     No     | Name of the tenant                                                 |
|   `state`   |   `int`   |    Yes    | 1 (active) | State of the tenant, either `active` (1) or `inactive` (2)         |

### Constraints

|     Constraint Name     |  Column(s)  |  Type   | Description                                                  |
|:-----------------------:|:-----------:|:-------:|--------------------------------------------------------------|
|     `pk_tenant_id`      |    `id`     | Primary |                                                              |
| `uid_tenant_public_id` | `public_id` | Unique  |                                                              |
|   `uid_tenant_name`    |   `name`    | Unique  | The name of the tenant must be unique                        |

### Others

- There is a `master` tenant with `name` of `VN Workday` that is created by default and cannot be deleted. This tenant is used for system-wide configurations and settings.