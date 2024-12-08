Para configurar adequadamente o **Grafana** em um ambiente Docker e monitorar as demais máquinas, você precisará:

1. **Configurar o Grafana (Container Docker)**  
2. **Configurar as máquinas monitoradas com Prometheus, Node Exporter e outros exporters**  
3. **Conectar os serviços no Grafana**  

Segue o guia detalhado:

---

### **Passo 1: Configuração do Grafana no Docker**

Certifique-se de que o Grafana esteja instalado e funcionando corretamente.

#### 1.1 **Verifique o contêiner Grafana**
Use o seguinte comando para verificar se o Grafana está rodando:
```bash
docker ps
```

#### 1.2 **Configurar o Docker Compose (opcional)**  
Se o Grafana ainda não estiver configurado, crie um arquivo `docker-compose.yml`:
```yaml
version: '3.8'
services:
  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3000:3000"
    volumes:
      - ./grafana/data:/var/lib/grafana
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=admin
```

Inicie o contêiner:
```bash
docker-compose up -d
```

Acesse o Grafana no navegador: `http://<IP_DO_SERVIDOR>:3000`  
**Usuário e senha padrão:** `admin/admin` (você pode alterar no `.yml`).

---

### **Passo 2: Configurar Prometheus e Exporters nas Demais Máquinas**

O Grafana precisa de uma fonte de dados, como o **Prometheus**, para coletar métricas de suas máquinas.

#### 2.1 **Instalar o Prometheus em uma Máquina Central**
Essa máquina central será o servidor Prometheus que coleta métricas de todos os servidores.  
Crie um arquivo `prometheus.yml` para configuração:

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'node_exporter'
    static_configs:
      - targets:
        - '192.168.0.101:9100'  # IP de um servidor com Node Exporter
        - '192.168.0.102:9100'  # IP de outro servidor com Node Exporter
```

Substitua os IPs pelas suas máquinas.  

#### 2.2 **Execute o Prometheus no Docker**
Adicione o Prometheus como um serviço Docker:
```yaml
version: '3.8'
services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
```

Inicie o serviço:
```bash
docker-compose up -d
```

Acesse o Prometheus em `http://<IP_DO_SERVIDOR>:9090`.

#### 2.3 **Instalar Node Exporter em Cada Máquina**
No Ubuntu Server, instale o Node Exporter:
```bash
wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz
tar -xzf node_exporter-1.6.1.linux-amd64.tar.gz
cd node_exporter-1.6.1.linux-amd64
sudo ./node_exporter
```

**Recomendações:**  
- Configure o Node Exporter para iniciar com o sistema usando `systemd`.  
- Certifique-se de que a porta 9100 esteja acessível a partir do Prometheus.

#### 2.4 **Exporters Adicionais**
- **PostgreSQL Exporter**: Para monitorar o PostgreSQL.
- **Nginx Exporter**: Para monitorar métricas do Nginx.
- **Docker Exporter**: Para métricas de contêineres Docker.  

Por exemplo, para PostgreSQL:
```bash
docker run --name=postgres-exporter \
  -e DATA_SOURCE_NAME="postgresql://user:password@host:5432/dbname" \
  -p 9187:9187 quay.io/prometheuscommunity/postgres-exporter
```

---

### **Passo 3: Configuração no Grafana**

#### 3.1 **Adicione o Prometheus como Data Source**
1. Acesse o Grafana (`http://<IP_DO_SERVIDOR>:3000`).
2. Vá para **Configuration > Data Sources**.
3. Clique em **Add Data Source** e escolha **Prometheus**.
4. Insira o URL do Prometheus: `http://<IP_DO_PROMETHEUS>:9090`.
5. Salve e teste a conexão.

#### 3.2 **Importe Dashboards Padrão**
- No Grafana, vá em **Dashboards > Import**.
- Utilize IDs de dashboards prontos da comunidade:
  - **Node Exporter Dashboard**: ID `1860`.
  - **Docker Dashboard**: ID `1229`.
  - **PostgreSQL Dashboard**: ID `9628`.

#### 3.3 **Crie Dashboards Personalizados**
- Use os dados do Prometheus para criar gráficos personalizados no Grafana.
- Exemplos de métricas:
  - **CPU e memória:** `node_cpu_seconds_total`, `node_memory_MemAvailable_bytes`.
  - **PostgreSQL:** `pg_stat_database_blks_read`.
  - **Docker:** `container_memory_usage_bytes`.

---

### **Passo 4: Configuração de Alertas no Grafana**

1. Vá para **Alerting > Notification Channels**.
2. Configure canais (e-mail, Slack, Telegram, etc.).
3. Crie regras de alerta no painel: **Create Alert > Query**.
4. Configure alertas baseados em métricas críticas (e.g., alta CPU, falta de memória).

---

### **Resumo**

1. **Máquina Central**:  
   - Execute **Prometheus** para coletar métricas de todas as máquinas.
   - Adicione exporters conforme necessário (Node Exporter, PostgreSQL Exporter, etc.).

2. **Demais Máquinas**:  
   - Configure Node Exporter para enviar métricas a Prometheus.

3. **Grafana**:  
   - Conecte o Prometheus como data source.
   - Crie e importe dashboards para monitorar seus serviços.

Essa arquitetura é escalável e permitirá monitorar seu ambiente completo de 10 servidores e serviços com alta eficiência.
