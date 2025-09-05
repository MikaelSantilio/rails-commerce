# Desafio técnico e-commerce

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
