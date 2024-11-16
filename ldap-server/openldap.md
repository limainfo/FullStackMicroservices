Para criar um servidor LDAP com usuários pré-definidos e atributos personalizados utilizando o Docker e a imagem bitnami/openldap, siga os passos abaixo:

Passo 1: Criar a rede Docker
Crie uma rede Docker chamada evaldo-full-stack com o subnet 10.0.0.0/24 para controlar o IP dos contêineres:

bash
Copiar código
docker network create --subnet=10.0.0.0/24 evaldo-full-stack
Passo 2: Preparar os arquivos LDIF
Crie um diretório para armazenar os arquivos LDIF:

bash
Copiar código
mkdir -p ldap-data/ldifs
2.1 Criar o arquivo de esquema personalizado
Crie um arquivo chamado 1_custom_schema.ldif dentro do diretório ldap-data/ldifs com o seguinte conteúdo:

ldif
Copiar código
dn: cn=custom,cn=schema,cn=config
objectClass: olcSchemaConfig
cn: custom
olcAttributeTypes: ( 1.3.6.1.4.1.99999.1 NAME 'cpf' DESC 'CPF' EQUALITY caseIgnoreMatch SYNTAX OMsDirectoryString SINGLE-VALUE )
olcAttributeTypes: ( 1.3.6.1.4.1.99999.2 NAME 'rg' DESC 'RG' EQUALITY caseIgnoreMatch SYNTAX OMsDirectoryString SINGLE-VALUE )
olcAttributeTypes: ( 1.3.6.1.4.1.99999.3 NAME 'funcao' DESC 'Função' EQUALITY caseIgnoreMatch SYNTAX OMsDirectoryString SINGLE-VALUE )
olcAttributeTypes: ( 1.3.6.1.4.1.99999.4 NAME 'local' DESC 'Local' EQUALITY caseIgnoreMatch SYNTAX OMsDirectoryString SINGLE-VALUE )
olcAttributeTypes: ( 1.3.6.1.4.1.99999.5 NAME 'nomeGuerra' DESC 'Nome de Guerra' EQUALITY caseIgnoreMatch SYNTAX OMsDirectoryString SINGLE-VALUE )
olcObjectClasses: ( 1.3.6.1.4.1.99999.10 NAME 'customPerson' SUP inetOrgPerson STRUCTURAL MAY ( cpf $ rg $ funcao $ local $ nomeGuerra ) )
Nota: Os números OID usados aqui (1.3.6.1.4.1.99999.x) são exemplos. Em um ambiente de produção, você deve usar OIDs registrados.

2.2 Criar o arquivo de usuários
Crie um arquivo chamado 2_users.ldif dentro do diretório ldap-data/ldifs com o seguinte conteúdo:

ldif
Copiar código
dn: ou=People,dc=evaldofullstack,dc=com,dc=br
objectClass: organizationalUnit
ou: People

dn: uid=usuario,ou=People,dc=evaldofullstack,dc=com,dc=br
objectClass: customPerson
cn: Usuário
sn: Usuário
uid: usuario
userPassword: ldapusuario
cpf: 12345678900
rg: 1234567
funcao: chefe
local: setor pessoal
nomeGuerra: usuário
title: CV
postalAddress: Brasília

dn: uid=admin,ou=People,dc=evaldofullstack,dc=com,dc=br
objectClass: customPerson
cn: Admin
sn: Admin
uid: admin
userPassword: ldapadmin
cpf: 45678912300
rg: 7654321
funcao: gerente
local: setor pessoal
nomeGuerra: admin
title: CV
postalAddress: Brasília
Passo 3: Executar o contêiner OpenLDAP
Crie um arquivo docker-compose.yml no diretório raiz do projeto com o seguinte conteúdo:

yaml
Copiar código
version: '3.7'

services:
  openldap:
    image: bitnami/openldap:latest
    container_name: openldap-server
    networks:
      evaldo-full-stack:
        ipv4_address: 10.0.0.1
    environment:
      - LDAP_ROOT=dc=evaldofullstack,dc=com,dc=br
      - LDAP_ADMIN_USERNAME=admin
      - LDAP_ADMIN_PASSWORD=ldapadmin
    volumes:
      - ./ldap-data/ldifs:/ldifs
      - openldap_data:/bitnami
    ports:
      - "389:389"
      - "636:636"

networks:
  evaldo-full-stack:
    driver: bridge
    ipam:
      config:
        - subnet: 10.0.0.0/24

volumes:
  openldap_data:
Execute o contêiner:

bash
Copiar código
docker-compose up -d
Passo 4: Verificar a inicialização e carregar os dados
O contêiner irá automaticamente aplicar os arquivos LDIF ao iniciar. Para verificar se os usuários foram adicionados, você pode usar um cliente LDAP como o ldapsearch.

Instale o ldap-utils (se ainda não tiver):

bash
Copiar código
sudo apt-get install ldap-utils
Execute uma busca LDAP:

bash
Copiar código
ldapsearch -x -H ldap://10.0.0.1 -b "dc=evaldofullstack,dc=com,dc=br" -D "cn=admin,dc=evaldofullstack,dc=com,dc=br" -w ldapadmin
Você deve ver os usuários usuario e admin listados com seus atributos.

Considerações Finais
Customização do Esquema: A adição de atributos personalizados requer a extensão do esquema LDAP. No exemplo acima, criamos um esquema personalizado dentro do arquivo 1_custom_schema.ldif.

Permissões e Segurança: Certifique-se de que os arquivos LDIF tenham as permissões corretas e que não estejam acessíveis publicamente em ambientes de produção.

Clientes LDAP: Para gerenciar o LDAP de forma mais amigável, considere usar ferramentas como phpLDAPadmin ou LDAP Account Manager.

Referências
Documentação do Bitnami OpenLDAP
Como estender esquemas no OpenLDAP
Espero que este guia tenha ajudado você a configurar seu servidor LDAP com os requisitos especificados. Se tiver alguma dúvida ou precisar de assistência adicional, não hesite em perguntar!