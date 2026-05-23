{{ config(materialized='table') }}

SELECT 
    value:id::INT AS movie_id,
    value:title::STRING AS title,
    value:release_date::DATE AS release_date,
    value:vote_average::FLOAT AS rating,
    value:vote_count::INT AS vote_count
FROM {{ source('tmdb_raw', 'raw_movies') }},
LATERAL FLATTEN(input => json_data:results)
