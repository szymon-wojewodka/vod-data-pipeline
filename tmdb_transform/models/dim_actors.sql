{{ config(materialized='table') }}

WITH raw_data AS (
    SELECT json_data FROM {{ source('tmdb_raw', 'raw_movies') }}
),

flattened_movies AS (
    SELECT 
        value:credits.cast AS cast_list
    FROM raw_data,
    LATERAL FLATTEN(input => json_data:results)
),

flattened_cast AS (
    SELECT
        c.value:id::INT AS actor_id,
        c.value:name::STRING AS actor_name,
        c.value:gender::INT AS gender,
        c.value:popularity::FLOAT AS popularity
    FROM flattened_movies,
    LATERAL FLATTEN(input => cast_list) c
)

SELECT 
    actor_id,
    MAX(actor_name) AS actor_name,
    MAX(gender) AS gender,
    MAX(popularity) AS popularity
FROM flattened_cast
WHERE actor_id IS NOT NULL
GROUP BY actor_id
