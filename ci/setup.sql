create database :"dbname";
create role :"username" with password ':"password"' login;
grant all privileges on database :"dbname" to :"username";

\c :"dbname";

create schema :"schema" authorization :"username";
alter database :"dbname" set search_path to :"schema";

create extension if not exists pgcrypto;

create or replace function get_optimized_bytes_factor(
    alp text
)
    returns float
    language plpgsql
as
$$
declare
    output float;
begin
    with input as (select alp as "alphabet")
    select round(1 +
                 abs((((2 << cast(floor(log(length(alphabet) - 1) / log(2)) as int)) - 1) - length(alphabet)::numeric) /
                     length(alphabet)), 2) as "Optimal additional bytes factor"
    from input
    into output;
    return output;
end;
$$;

-- Generates an optimized random string of a specified size using the given alphabet, mask, and step.
-- This optimized version is designed for higher performance and lower memory overhead.
-- No checks are performed! Use it only if you really know what you are doing.
CREATE OR REPLACE FUNCTION nanoid_optimized(
    size int, -- The desired length of the generated string.
    alphabet text, -- The set of characters to choose from for generating the string.
    mask int, -- The mask used for mapping random bytes to alphabet indices. Should be `(2^n) - 1` where `n` is a power of 2 less than or equal to the alphabet size.
    step int -- The number of random bytes to generate in each iteration. A larger value may speed up the function but increase memory usage.
)
    RETURNS text -- A randomly generated NanoId String
    LANGUAGE plpgsql
    VOLATILE
    PARALLEL SAFE
AS
$$
DECLARE
    idBuilder      text := '';
    counter        int  := 0;
    bytes          bytea;
    alphabetIndex  int;
    alphabetArray  text[];
    alphabetLength int  := 64;
BEGIN
    alphabetArray := regexp_split_to_array(alphabet, '');
    alphabetLength := array_length(alphabetArray, 1);

    LOOP
        bytes := gen_random_bytes(step);
        FOR counter IN 0..step - 1
            LOOP
                alphabetIndex := (get_byte(bytes, counter) & mask) + 1;
                IF alphabetIndex <= alphabetLength THEN
                    idBuilder := idBuilder || alphabetArray[alphabetIndex];
                    IF length(idBuilder) = size THEN
                        RETURN idBuilder;
                    END IF;
                END IF;
            END LOOP;
    END LOOP;
END
$$;

-- The `nanoid()` function generates a compact, URL-friendly unique identifier.
-- Based on the given size and alphabet, it creates a randomized string that's ideal for
-- use-cases requiring small, unpredictable IDs (e.g., URL shorteners, generated file names, etc.).
-- While it comes with a default configuration, the function is designed to be flexible,
-- allowing for customization to meet specific needs.
CREATE OR REPLACE FUNCTION nanoid(
    size int DEFAULT 21, -- The number of symbols in the NanoId String. Must be greater than 0.
    alphabet text DEFAULT '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ' -- The symbols used in the NanoId String. Must contain between 1 and 255 symbols.
)
    RETURNS text -- A randomly generated NanoId String
    LANGUAGE plpgsql
    VOLATILE
    PARALLEL SAFE
AS
$$
DECLARE
    alphabetArray         text[];
    alphabetLength        int;
    mask                  int;
    step                  int;
    additionalBytesFactor float;
BEGIN
    IF size IS NULL OR size < 1 THEN
        RAISE EXCEPTION 'The size must be defined and greater than 0!';
    END IF;

    IF alphabet IS NULL OR length(alphabet) = 0 OR length(alphabet) > 255 THEN
        RAISE EXCEPTION 'The alphabet can''t be undefined, zero or bigger than 255 symbols!';
    END IF;

    additionalBytesFactor := get_optimized_bytes_factor(alphabet);

    alphabetArray := regexp_split_to_array(alphabet, '');
    alphabetLength := array_length(alphabetArray, 1);
    mask := (2 << cast(floor(log(alphabetLength - 1) / log(2)) as int)) - 1;
    step := cast(ceil(additionalBytesFactor * mask * size / alphabetLength) AS int);

    IF step > 1024 THEN
        step := 1024; -- The step size % can''t be bigger then 1024!
    END IF;

    RETURN nanoid_optimized(size, alphabet, mask, step);
END
$$;