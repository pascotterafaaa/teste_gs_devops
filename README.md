# AstroTrack - DevOps, Docker E Azure

Este material descreve como executar o **AstroTrack** em uma VM Linux na Azure usando Docker Compose com dois containers:

- `app-astrotrack-563210`: API Java Spring Boot.
- `db-astrotrack-563210`: banco Oracle XE.

## 1. Descricao Do Projeto

O **AstroTrack** e uma API REST para logistica satelital no espaco sideral. A aplicacao controla clientes, motoristas/pilotos, veiculos espaciais, viagens e checkpoints de rastreamento.

A solucao simula uma operacao de transporte espacial, registrando missoes, rotas, eventos de seguranca, posicoes de rastreamento, botao de panico e abertura de porta.

O backend foi desenvolvido em **Java 21 com Spring Boot 3** e utiliza **Oracle SQL** para persistencia dos dados.

## 2. Beneficios Para O Negocio

- Monitoramento de viagens espaciais e satelitais.
- Controle de clientes, motoristas/pilotos, veiculos, viagens e checkpoints.
- Registro de eventos criticos como botao de panico e porta aberta.
- Persistencia dos dados em Oracle XE.
- API protegida com JWT.
- Documentacao disponivel via Swagger/OpenAPI.
- Base pronta para integracao com dashboards e sistemas logisticos.

## 3. Desenho Macro Da Arquitetura

O desenho macro da arquitetura deve ser colocado no PDF final da entrega.

Imagem sugerida:

```text
teste_gs_devops/arquitetura.png
```

Fluxo em nuvem:

```text
Usuario/Postman/Swagger
        |
        v
Azure VM - porta 8080
        |
        v
Container app-astrotrack-563210
        |
        v
Rede Docker astrotrack_network
        |
        v
Container db-astrotrack-563210
        |
        v
Volume nomeado astro_oracle_data
```

A API e o banco rodam em containers diferentes, na mesma rede Docker. A aplicacao acessa o Oracle pelo nome do servico `db-astrotrack`.

## 4. Rotas Principais

### Auth

| Metodo | Rota | Descricao |
|---|---|---|
| POST | `/auth/register` | Cria usuario e retorna JWT |
| POST | `/auth/login` | Autentica usuario e retorna JWT |

### Health E Swagger

| Metodo | Rota | Descricao |
|---|---|---|
| GET | `/` | Verifica se a API esta online |
| GET | `/health` | Health check da aplicacao |
| GET | `/swagger-ui/index.html` | Interface Swagger |
| GET | `/v3/api-docs` | JSON OpenAPI |

### CRUD Principal

| Metodo | Rota | Descricao |
|---|---|---|
| GET | `/clientes` | Lista clientes |
| POST | `/clientes` | Cria cliente |
| GET | `/clientes/{id}` | Busca cliente por ID |
| PUT | `/clientes/{id}` | Atualiza cliente |
| DELETE | `/clientes/{id}` | Remove cliente |
| GET | `/motoristas` | Lista motoristas |
| POST | `/motoristas` | Cria motorista |
| GET | `/motoristas/{id}` | Busca motorista por ID |
| PUT | `/motoristas/{id}` | Atualiza motorista |
| DELETE | `/motoristas/{id}` | Remove motorista |
| GET | `/veiculos` | Lista veiculos |
| POST | `/veiculos` | Cria veiculo |
| GET | `/veiculos/{id}` | Busca veiculo por ID |
| PUT | `/veiculos/{id}` | Atualiza veiculo |
| DELETE | `/veiculos/{id}` | Remove veiculo |
| GET | `/viagens` | Lista viagens |
| POST | `/viagens` | Cria viagem |
| GET | `/viagens/{id}` | Busca viagem por ID |
| PUT | `/viagens/{id}` | Atualiza viagem |
| DELETE | `/viagens/{id}` | Remove viagem |
| GET | `/checkpoints` | Lista checkpoints |
| POST | `/checkpoints` | Cria checkpoint |
| GET | `/checkpoints/{id}` | Busca checkpoint por ID |
| PUT | `/checkpoints/{id}` | Atualiza checkpoint |
| DELETE | `/checkpoints/{id}` | Remove checkpoint |

### HATEOAS

| Metodo | Rota | Descricao |
|---|---|---|
| GET | `/hateoas` | Menu geral HATEOAS |
| GET | `/clientes/hateoas` | Links HATEOAS de clientes |
| GET | `/motoristas/hateoas` | Links HATEOAS de motoristas |
| GET | `/veiculos/hateoas` | Links HATEOAS de veiculos |
| GET | `/viagens/hateoas` | Links HATEOAS de viagens |
| GET | `/checkpoints/hateoas` | Links HATEOAS de checkpoints |

## 5. Arquivos Da Entrega DevOps

```text
teste_gs_devops/
├── app/
│   └── Dockerfile
├── docker-compose.yml
├── init.sh
├── init.sql
└── README.md
```

O projeto Java e o projeto DevOps ficam separados. O `docker-compose.yml` foi configurado para buscar o codigo Java em `../GS_java`.

## 6. How To - Execucao Na Azure

Este passo a passo considera uma VM Linux na Azure com Docker e Docker Compose Plugin instalados.

### 6.1 Clonar Os Repositorios

Na VM:

```bash
cd /home/admlnx
git clone LINK_DO_REPOSITORIO_JAVA GS_java
git clone LINK_DO_REPOSITORIO_DEVOPS teste_gs_devops
```

Conferir:

```bash
ls
ls GS_java
ls teste_gs_devops
```

### 6.2 Conferir Docker

```bash
docker --version
docker compose version
```

Se `docker-compose` nao funcionar, use `docker compose`, com espaco.

### 6.3 Subir App E Banco

Entre na pasta DevOps:

```bash
cd /home/admlnx/teste_gs_devops
```

Para subir do zero, apagando volume antigo:

```bash
docker compose down -v --remove-orphans
chmod +x init.sh
docker compose up -d --build
```

O Docker Compose vai:

- Construir a imagem personalizada da API.
- Subir o Oracle XE.
- Criar a rede `astrotrack_network`.
- Criar o volume nomeado `astro_oracle_data`.
- Executar o `init.sh`, que roda o `init.sql` no schema `ASTRO_USER` na primeira criacao do volume.
- Criar as tabelas `AT_CLIENTES`, `AT_MOTORISTAS`, `AT_VEICULOS`, `AT_VIAGENS`, `AT_CHECKPOINTS` e `AT_USUARIOS_SISTEMA`.
- Subir a API na porta `8080`.

### 6.4 Verificar Containers

```bash
docker compose ps
```

Resultado esperado:

```text
db-astrotrack-563210    Up ... (healthy)    0.0.0.0:1521->1521/tcp
app-astrotrack-563210   Up ...              0.0.0.0:8080->8080/tcp
```

### 6.5 Verificar Logs

```bash
docker compose logs db-astrotrack
docker compose logs app-astrotrack
docker compose logs app-astrotrack --tail=200
```

### 6.6 Testar A API

Dentro da VM:

```bash
curl http://localhost:8080/health
```

Pelo IP publico:

```bash
curl http://IP_PUBLICO_DA_VM:8080/health
```

Swagger:

```text
http://IP_PUBLICO_DA_VM:8080/swagger-ui/index.html
```

## 7. Docker Compose

O `docker-compose.yml` cria:

- Banco Oracle em `db-astrotrack-563210`.
- API Java em `app-astrotrack-563210`.
- Rede Docker `astrotrack_network`.
- Volume nomeado `astro_oracle_data`.

Trecho principal:

```yaml
services:
  db-astrotrack:
    image: gvenzl/oracle-xe:21-slim
    container_name: db-astrotrack-563210
    restart: unless-stopped
    environment:
      ORACLE_PASSWORD: astro_sys_password
      APP_USER: ASTRO_USER
      APP_USER_PASSWORD: astro_password
    ports:
      - "1521:1521"
    volumes:
      - astro_oracle_data:/opt/oracle/oradata
      - ./init.sh:/container-entrypoint-initdb.d/init.sh:ro
      - ./init.sql:/opt/astrotrack/init.sql:ro
    networks:
      - astrotrack_network
    healthcheck:
      test: ["CMD", "healthcheck.sh"]
      interval: 10s
      timeout: 5s
      retries: 40
      start_period: 120s

  app-astrotrack:
    container_name: app-astrotrack-563210
    image: astrotrack-api-563210:1.0.0
    build:
      context: ${ASTROTRACK_JAVA_CONTEXT:-../GS_java}
      dockerfile: ${ASTROTRACK_APP_DOCKERFILE:-../teste_gs_devops/app/Dockerfile}
    restart: unless-stopped
    depends_on:
      db-astrotrack:
        condition: service_healthy
    environment:
      SPRING_DATASOURCE_URL: jdbc:oracle:thin:@//db-astrotrack:1521/XEPDB1
      SPRING_DATASOURCE_USERNAME: ASTRO_USER
      SPRING_DATASOURCE_PASSWORD: astro_password
      ORACLE_DB_URL: jdbc:oracle:thin:@//db-astrotrack:1521/XEPDB1
      ORACLE_DB_USERNAME: ASTRO_USER
      ORACLE_DB_PASSWORD: astro_password
      SPRING_JPA_HIBERNATE_DDL_AUTO: validate
      ASTROTRACK_JWT_SECRET: astrotrack-devops-secret-key-rm-563210-change-before-production
      ASTROTRACK_JWT_EXPIRATION_MINUTES: "120"
      SERVER_PORT: "8080"
    ports:
      - "8080:8080"
    networks:
      - astrotrack_network

volumes:
  astro_oracle_data:
    name: astro_oracle_data

networks:
  astrotrack_network:
    name: astrotrack_network
    driver: bridge
```

## 8. Testes Pelo Postman

No Postman, use sempre o IP publico da VM:

```text
base_url = http://IP_PUBLICO_DA_VM:8080
```

### 8.1 Health Check

```text
GET {{base_url}}/health
```

Resposta esperada:

```text
OK
```

### 8.2 Criar Usuario

```text
POST {{base_url}}/auth/register
```

Body:

```json
{
  "usuario": "admin",
  "email": "admin@astrotrack.com",
  "senha": "senha123"
}
```

### 8.3 Fazer Login

```text
POST {{base_url}}/auth/login
```

Body:

```json
{
  "email": "admin@astrotrack.com",
  "senha": "senha123"
}
```

Copie o token retornado e use em:

```text
Authorization > Type: Bearer Token
```

### 8.4 Rotas Para Testar

| Metodo | URL | Observacao |
|---|---|---|
| GET | `{{base_url}}/health` | API online |
| GET | `{{base_url}}/swagger-ui/index.html` | Swagger |
| POST | `{{base_url}}/auth/register` | Criar usuario |
| POST | `{{base_url}}/auth/login` | Login |
| POST | `{{base_url}}/clientes` | Criar cliente |
| GET | `{{base_url}}/clientes` | Listar clientes |
| POST | `{{base_url}}/motoristas` | Criar motorista |
| GET | `{{base_url}}/motoristas` | Listar motoristas |
| POST | `{{base_url}}/veiculos` | Criar veiculo |
| GET | `{{base_url}}/veiculos` | Listar veiculos |
| POST | `{{base_url}}/viagens` | Criar viagem |
| GET | `{{base_url}}/viagens` | Listar viagens |
| POST | `{{base_url}}/checkpoints` | Criar checkpoint |
| GET | `{{base_url}}/checkpoints` | Listar checkpoints |

Importante: use `http`, nao `https`.

## 9. Teste Rapido Via Curl

Defina a URL:

```bash
export API_BASE_URL=http://IP_PUBLICO_DA_VM:8080
```

Registrar usuario:

```bash
curl -X POST "$API_BASE_URL/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "usuario": "admin",
    "email": "admin@astrotrack.com",
    "senha": "senha123"
  }'
```

Fazer login:

```bash
TOKEN=$(curl -s -X POST "$API_BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@astrotrack.com",
    "senha": "senha123"
  }' | sed -n 's/.*"token":"\([^"]*\)".*/\1/p')
```

Criar cliente:

```bash
curl -X POST "$API_BASE_URL/clientes" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "nome": "Orbital Cargo Solutions LTDA",
    "cnpj": "04.252.011/0001-10",
    "email": "contato@orbitalcargo.com",
    "telefone": "(48) 9839-3927",
    "status": "ATIVO"
  }'
```

## 10. Verificar Persistencia No Oracle

Entrar no Oracle:

```bash
docker container exec -it db-astrotrack-563210 sqlplus ASTRO_USER/astro_password@//localhost:1521/XEPDB1
```

Consultar tabelas:

```sql
SHOW USER;
SELECT table_name FROM user_tables ORDER BY table_name;
SELECT * FROM AT_CLIENTES;
SELECT * FROM AT_MOTORISTAS;
SELECT * FROM AT_VEICULOS;
SELECT * FROM AT_VIAGENS;
SELECT * FROM AT_CHECKPOINTS;
SELECT * FROM AT_USUARIOS_SISTEMA;
EXIT;
```

## 11. Evidencias Para Apresentacao

Executar em segundo plano:

```bash
docker compose up -d --build
```

Exibir logs:

```bash
docker compose logs db-astrotrack
docker compose logs app-astrotrack
```

Demonstrar usuario e diretorio da API:

```bash
docker container exec -it app-astrotrack-563210 whoami
docker container exec -it app-astrotrack-563210 pwd
docker container exec -it app-astrotrack-563210 ls -la
```

Demonstrar usuario e diretorio do banco:

```bash
docker container exec -it db-astrotrack-563210 whoami
docker container exec -it db-astrotrack-563210 pwd
docker container exec -it db-astrotrack-563210 ls -la
```

Demonstrar persistencia:

```bash
docker container exec -it db-astrotrack-563210 sqlplus ASTRO_USER/astro_password@//localhost:1521/XEPDB1
```

```sql
SELECT table_name FROM user_tables ORDER BY table_name;
SELECT id_cliente, nome, email FROM AT_CLIENTES;
EXIT;
```

## 12. Liberar Porta 8080 Na Azure

Caso o Postman nao consiga acessar a API pelo IP publico, libere a porta 8080:

```bash
az vm open-port --resource-group NOME_DO_RESOURCE_GROUP --name NOME_DA_VM --port 8080 --priority 1001
```

## 13. Erros Comuns

### docker-compose: command not found

Use:

```bash
docker compose version
docker compose up -d --build
```

### unable to prepare context

Confirme se a pasta Java esta em:

```text
/home/admlnx/GS_java
```

e a pasta DevOps esta em:

```text
/home/admlnx/teste_gs_devops
```

### Up Less than a second Ou Restarting

Significa que a API esta iniciando e caindo.

Veja o log:

```bash
docker compose logs app-astrotrack --tail=200
```

Se aparecer tabela faltando, recrie o ambiente:

```bash
docker compose down -v --remove-orphans
chmod +x init.sh
docker compose up -d --build
```

### ECONNREFUSED No Postman

Verifique dentro da VM:

```bash
curl http://localhost:8080/health
```

Se funcionar dentro da VM, mas nao fora, libere a porta 8080 na Azure. Tambem confira se voce esta usando `http`, nao `https`.

## 14. Parar Ou Remover O Ambiente

Parar sem apagar dados:

```bash
docker compose down
```

Apagar containers e volume do banco:

```bash
docker compose down -v --remove-orphans
```

## 15. Remover Recursos Da Azure

```bash
az group delete --name NOME_DO_RESOURCE_GROUP --yes --no-wait
```
