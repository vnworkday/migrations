# FAQs & Troubleshooting

## Rules of thumb

1. **Do NOT modify migration scripts** after they have been applied to the database. If you need to make changes to the migration scripts, create a new migration script instead.

2. **Do NOT delete migration scripts** that have been applied to the database. If you need to remove a migration script, create a new migration script to undo the changes.

## Common Issues

1. **Flyway or PostgreSQL Server container is not running**

    - **Symptoms**: When you run `docker ps`, you do not see the Flyway container.
    - **Solution**: Run the `ci/start.sh` script to start the Flyway container.

2. **Checksum mismatch error**


    - **Symptoms**: When you run `ci/migrate.sh`, you see an error message that says `Checksum mismatch`.
    - **Solution**: Run the `ci/repair.sh` script to repair the Flyway metadata table.

        ```shell
        ./ci/repair.sh $db_name
        ```

    - **Note**: This error likely occurs if anyone tried to modify/format a migration script after it has been applied to the database.
