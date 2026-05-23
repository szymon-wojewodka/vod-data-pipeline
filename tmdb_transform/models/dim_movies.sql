{{ config(materialized='table') }}

WITH raw_data AS (
    SELECT json_data FROM {{ source('tmdb_raw', 'raw_movies') }}
),

flattened_movies AS (
    SELECT 
        value:id::INT AS movie_id,
        value:title::STRING AS title,
        value:release_date::DATE AS release_date,
        value:vote_average::FLOAT AS rating,
        value:vote_count::INT AS vote_count,
        value:popularity::FLOAT AS popularity,
        value:original_language::STRING AS original_language
    FROM raw_data,
    LATERAL FLATTEN(input => json_data:results)
)

SELECT * FROM flattened_movies
QUALIFY ROW_NUMBER() OVER (PARTITION BY movie_id ORDER BY popularity DESC) = 1
