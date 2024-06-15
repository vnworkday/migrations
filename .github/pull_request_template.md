## Change Type

- [ ] DDL (Schema change: create, alter, drop)
- [ ] DML (Data change: insert, update, delete)

## General Checklist

- [ ] **DO NOT** include any sensitive information in the PR
- [ ] **DO NOT** make migration idempotent (e.g. `... IF NOT EXISTS ...`). Migrations are stateful, so idempotent migrations can result in schema drift accross environments.
- [ ] The migration conforms to the [Relational Database Checklist and Best Practices](https://www.notion.so/ntduycse/Relational-Database-Checklist-and-Best-Practices-70e1f2f8c7094cba883822b332d8b322?pvs=4)

## DDL Checklist (skipped if DML)

- [ ] I've already attached screenshots of the schema changes
- [ ] I've **NOT** use `ALTER TABLE ... ALTER COLUMN ...` to change column type or set default value on any existing column
- [ ] I've already attached the execution plan before and after the schema changes reasoning why the change is necessary