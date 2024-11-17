#!/bin/bash
set -e

# Aplicar o esquema personalizado
echo "Aplicando o esquema personalizado..."
slapadd -F /opt/bitnami/openldap/etc/slapd.d -n 0 -l /docker-entrypoint-initdb.d/01-custom_schema.ldif

# Adicionar usuários
echo "Adicionando usuários..."
slapadd -F /opt/bitnami/openldap/etc/slapd.d -b "${LDAP_ROOT}" -l /docker-entrypoint-initdb.d/02-users.ldif
