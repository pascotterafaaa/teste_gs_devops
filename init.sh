#!/bin/bash
set -e

echo "Criando tabelas do AstroTrack no schema ASTRO_USER..."

sqlplus -s "${APP_USER}/${APP_USER_PASSWORD}@//localhost:1521/XEPDB1" <<EOF
@/opt/astrotrack/init.sql
EXIT;
EOF
