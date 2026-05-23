#!/bin/bash

set -e

set -a
source .env
set +a

python3 fetch_tmdb.py
