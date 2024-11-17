
Para adicionar o Java JDK 21 e o Apache Kafka ao seu contêiner Nginx e construir uma nova imagem com essas alterações, você precisará criar um Dockerfile personalizado que estenda a imagem `bitnami/nginx:latest`. Aqui estão os passos detalhados para fazer isso:

1. **Crie um Dockerfile personalizado**

   No mesmo diretório do seu `docker-compose.yml`, crie um arquivo chamado `Dockerfile.nginx-java-kafka` (ou apenas `Dockerfile` se preferir).

   ```dockerfile
   FROM bitnami/nginx:latest

   # Instalação de dependências
   USER root
   RUN install_packages wget tar

   # Instalação do OpenJDK 21
   RUN mkdir -p /usr/java && \
       cd /usr/java && \
       wget https://download.java.net/java/GA/jdk21/latest/jdk-21_linux-x64_bin.tar.gz && \
       tar -xzvf jdk-21_linux-x64_bin.tar.gz && \
       rm jdk-21_linux-x64_bin.tar.gz

   ENV JAVA_HOME=/usr/java/jdk-21
   ENV PATH=$JAVA_HOME/bin:$PATH

   # Instalação do Apache Kafka
   RUN mkdir /opt/kafka && \
       wget -qO - https://downloads.apache.org/kafka/3.5.1/kafka_2.13-3.5.1.tgz | tar xz --strip-components=1 -C /opt/kafka

   ENV PATH=$PATH:/opt/kafka/bin

   # Expor as portas do Kafka e Zookeeper
   EXPOSE 9092 2181

   # Copiar script de inicialização
   COPY start.sh /start.sh
   RUN chmod +x /start.sh

   # Comando para iniciar todos os serviços
   CMD ["/start.sh"]
   ```

2. **Crie o script `start.sh`**

   Crie um arquivo chamado `start.sh` no mesmo diretório:

   ```bash
   #!/bin/bash

   # Iniciar o Nginx
   /opt/bitnami/scripts/nginx/run.sh &

   # Iniciar o Zookeeper
   /opt/kafka/bin/zookeeper-server-start.sh /opt/kafka/config/zookeeper.properties &

   # Iniciar o Apache Kafka
   /opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/server.properties
   ```

3. **Modifique o seu `docker-compose.yml`**

   Atualize o serviço Nginx no seu `docker-compose.yml` para construir a nova imagem:

   ```yaml
   nginx:
     build:
       context: .
       dockerfile: Dockerfile.nginx-java-kafka
     container_name: nginx
     environment:
       - NGINX_ENABLE_STREAM=yes
     volumes:
       - ./www:/app
       - ./angular.conf:/opt/bitnami/nginx/conf/server_blocks/my_server_block.conf:ro
     ports:
       - "80:80"
       - "9092:9092"
       - "2181:2181"
     networks:
       evaldo-full-stack:
         ipv4_address: 10.0.0.6
   ```

4. **Construa e inicie os contêineres**

   Execute o seguinte comando para construir a nova imagem e iniciar os contêineres:

   ```bash
   docker-compose up --build
   ```

**Observações Importantes:**

- **Práticas Recomendadas:** Executar múltiplos serviços em um único contêiner não é uma prática recomendada em Docker. O ideal é ter cada serviço em seu próprio contêiner, permitindo melhor escalabilidade e manutenção.

- **Alternativa Recomendada:** Considere separar o Nginx, o Apache Kafka e o Zookeeper em contêineres distintos. Você pode utilizar imagens oficiais ou mantidas pela comunidade para o Kafka e o Zookeeper, e conectá-los via uma rede Docker.

- **Variáveis de Ambiente e Configurações:** Certifique-se de configurar corretamente as propriedades do Kafka e do Zookeeper, especialmente se estiver executando em um ambiente de produção.

- **Segurança:** Sempre mantenha as dependências e serviços atualizados para garantir a segurança do seu ambiente.

Seguindo esses passos, você terá uma nova imagem Docker que inclui o Nginx, o Java JDK 21 e o Apache Kafka, conforme suas necessidades.
