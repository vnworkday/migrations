# Account Database Schema (`vn_account`)

## Table: `vn_tenant`

### Schema

|    Name     | Data Type | Required? |  Default   | Description                                                        |
|:-----------:|:---------:|:---------:|:----------:|--------------------------------------------------------------------|
|    `id`     |   `int`   |    Yes    |     No     | Auto-incremented primary key, intended for internal usage          |
| `public_id` | `varchar` |    Yes    |     No     | Public identifier in form of `nanoid`, intended for external usage |
|   `name`    | `varchar` |    Yes    |     No     | Name of the tenant                                                 |
|   `state`   |   `int`   |    Yes    | 1 (active) | State of the tenant, either `active` (1) or `inactive` (0)         |

### Constraints

|     Constraint Name     |  Column(s)  |  Type   | Description                                                  |
|:-----------------------:|:-----------:|:-------:|--------------------------------------------------------------|
|     `pk_tenant_id`      |    `id`     | Primary |                                                              |
| `uidx_tenant_public_id` | `public_id` | Unique  |                                                              |
|   `uidx_tenant_name`    |   `name`    | Unique  | The name of the tenant must be unique                        |
|    `ck_tenant_state`    |   `state`   |  Check  | The `state` column must be either 0 (inactive) or 1 (active) |

### Others

- There is a `master` tenant with `public_id` of `vnworkday` and `name` of `VN Workday` that is created by default and
  cannot be deleted. This tenant is used for system-wide configurations and settings.