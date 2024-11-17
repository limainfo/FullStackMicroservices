
Aqui está o passo a passo para criar um contêiner Docker com PostgreSQL com os requisitos que você pediu:

### 1. Criar a Pasta Externa para os Dados do Banco
Escolha um diretório no host para armazenar os dados do PostgreSQL. Por exemplo:

```bash
mkdir -p /data/postgresql
```

Certifique-se de que a pasta tem permissões adequadas:

```bash
chmod 700 /data/postgresql
```

### 2. Criar o Contêiner do PostgreSQL
Use o comando abaixo para criar o contêiner PostgreSQL:

```bash
docker run -d \
  --name postgresql \
  --net evaldo-full-stack \
  --ip 10.0.0.5 \
  -e POSTGRES_USER=admin \
  -e POSTGRES_PASSWORD=adminpassword \
  -e POSTGRES_DB=mydatabase \
  -v /data/postgresql:/var/lib/postgresql/data \
  -p 5432:5432 \
  postgres:latest
```

### Parâmetros Explicados
- **`--net evaldo-full-stack`**: Conecta o contêiner à rede `evaldo-full-stack`.
- **`--ip 10.0.0.5`**: Define o IP fixo para o PostgreSQL.
- **`-e`**: Configura variáveis de ambiente (usuário, senha e banco padrão).
- **`-v`**: Faz o volume persistir os dados em `/data/postgresql`.
- **`-p 5432:5432`**: Mapeia a porta 5432 para acesso externo ao host.

### 3. Configurar Acesso Externo
Certifique-se de que o PostgreSQL está configurado para aceitar conexões de outros hosts. Edite os arquivos de configuração dentro do contêiner:

1. Entre no contêiner:
   ```bash
   docker exec -it postgresql bash
   ```

2. Altere o arquivo `postgresql.conf`:
   ```bash
   echo "listen_addresses = '*'" >> /var/lib/postgresql/data/postgresql.conf
   ```

3. Edite o arquivo `pg_hba.conf` para permitir conexões das máquinas específicas:
   ```bash
   echo "host all all 10.0.0.4/32 md5" >> /var/lib/postgresql/data/pg_hba.conf
   echo "host all all 10.0.0.5/32 md5" >> /var/lib/postgresql/data/pg_hba.conf
   echo "host all all 10.0.0.6/32 md5" >> /var/lib/postgresql/data/pg_hba.conf
   ```

4. Reinicie o contêiner para aplicar as alterações:
   ```bash
   docker restart postgresql
   ```

### 4. Testar Conexões
- Do servidor Kafka (10.0.0.4):
  ```bash
  psql -h 10.0.0.3 -U admin -d mydatabase
  ```
- Do servidor Nginx (10.0.0.5):
  ```bash
  psql -h 10.0.0.3 -U admin -d mydatabase
  ```

Pronto! Agora seu PostgreSQL está configurado para ser acessado pelos servidores com os IPs 10.0.0.4 e 10.0.0.3 na rede `ldap-network`.
