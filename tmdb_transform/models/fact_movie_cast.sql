{{ config(materialized='table') }}

WITH raw_data AS (
    SELECT json_data FROM {{ source('tmdb_raw', 'raw_movies') }}
),

flattened_movies AS (
    SELECT 
        value:id::INT AS movie_id,
        value:credits.cast AS cast_list
    FROM raw_data,
    LATERAL FLATTEN(input => json_data:results)
),

flattened_cast AS (
    SELECT
        movie_id,
        c.value:id::INT AS actor_id,
        c.value:character::STRING AS character_name,
        c.value:order::INT AS cast_order
    FROM flattened_movies,
    LATERAL FLATTEN(input => cast_list) c
)

SELECT * FROM flattened_cast
