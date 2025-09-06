# Desafio técnico e-commerce
## Descrição

Uma API completa para gerenciamento de carrinho de compras de e-commerce, incluindo funcionalidades de adicionar/remover produtos, gerenciamento de quantidades e sistema de carrinho abandonado com cleanup automático.

## Funcionalidades Implementadas

### **Gerenciamento de Carrinho**
- **Visualizar carrinho**: `GET /cart` - Retorna o carrinho atual da sessão
- **Adicionar produto novo**: `POST /cart` - Adiciona um produto que não está no carrinho
- **Incrementar quantidade**: `POST /cart/add_item` - Aumenta a quantidade de um produto existente
- **Remover produto**: `DELETE /cart/:product_id` - Remove completamente um produto do carrinho

### **Sistema de Carrinho Abandonado**
- **Marcação automática**: Carrinhos inativos por 3+ horas são marcados como abandonados
- **Limpeza automática**: Carrinhos abandonados há 7+ dias são removidos automaticamente
- **Jobs Sidekiq**: Processamento em background com agendamento via `sidekiq-scheduler`

### **Processamento Assíncrono**
- **MarkCartAsAbandonedJob**: Executa a cada minuto para marcar carrinhos abandonados
- **RemoveAbandonedCartJob**: Executa a cada hora para remover carrinhos antigos
- **Interface Sidekiq**: Disponível em `/sidekiq` para monitoramento

### Code Coverage
- 99% de cobertura do codigo

### **Makefile**
- O Makefile abstrai os comandos de execução da aplicação com Docker. É necessário instalar ele em sua máquina se nao tiver, com:
```bash
sudo apt update
sudo apt install make

```
- Comandos do Makefile

```bash
make start          # Inicia todos os serviços em background
make test           # Executa suite de testes com coverage
make logs-web       # Visualiza logs do servidor web
make rails-console  # Acesso ao console Rails
make db-migrate     # Executa migrações pendentes
make help           # Mostra todos os outros comandos
```

### **Setup Inicial**
```bash
# Clonar e navegar para o projeto
git clone <repo-url>
cd rails-commerce

# Iniciar ambiente completo
make start

# Configurar banco de dados (se necessário)
make db-migrate
make db-seed
```

### **Exemplo de Uso da API**
```bash
# Listar produtos disponíveis
curl http://localhost:3000/products

# Visualizar carrinho (vazio inicialmente)
curl http://localhost:3000/cart

# Adicionar produto ao carrinho
curl -X POST http://localhost:3000/cart \
  -H "Content-Type: application/json" \
  -d '{"product_id": 1, "quantity": 2}'

# Incrementar quantidade
curl -X POST http://localhost:3000/cart/add_item \
  -H "Content-Type: application/json" \
  -d '{"product_id": 1, "quantity": 1}'

# Remover produto
curl -X DELETE http://localhost:3000/cart/1
```



## Nossas expectativas

A equipe de engenharia da RD Station tem alguns princípios nos quais baseamos nosso trabalho diário. Um deles é: projete seu código para ser mais fácil de entender, não mais fácil de escrever.

Portanto, para nós, é mais importante um código de fácil leitura do que um que utilize recursos complexos e/ou desnecessários.

O que gostaríamos de ver:

- O código deve ser fácil de ler. Clean Code pode te ajudar.
- Notas gerais e informações sobre a versão da linguagem e outras informações importantes para executar seu código.
- Código que se preocupa com a performance (complexidade de algoritmo).
- O seu código deve cobrir todos os casos de uso presentes no README, mesmo que não haja um teste implementado para tal.
- A adição de novos testes é sempre bem-vinda.
- Você deve enviar para nós o link do repositório público com a aplicação desenvolvida (GitHub, BitBucket, etc.).

## Problemas encontrados
### 1. **Erro de Permissão no Schema.rb**
```
Permission denied @ rb_sysopen - /rails/db/schema.rb
```
**Causa**: Conflito entre UID do usuário no host vs container
- Usuário no host: `mikael` (UID 1002)  
- Usuário no container: `rails` (UID 1000)
- Quando volumes são montados, arquivos mantêm permissões do host

**Solução**: Configurar docker-compose para usar mesmo UID do host
```yaml
services:
  web:
    user: "${UID:-1000}:${GID:-1000}"
```

### 2. **Puma Inacessível Externamente**
```
curl: (7) Failed to connect to localhost port 3000: Connection refused
```

**Causa**: Puma fazendo bind apenas em `127.0.0.1` (localhost interno do container)
- `port 3000` é equivalente a `bind "tcp://127.0.0.1:3000"`
- Containers precisam escutar em todas as interfaces para aceitar conexões externas

**Solução**: Configurar bind para `0.0.0.0` no `config/puma.rb`
```ruby
# Remover: port ENV.fetch("PORT") { 3000 }
# Adicionar: bind "tcp://0.0.0.0:#{ENV.fetch("PORT") { 3000 }}"
```
