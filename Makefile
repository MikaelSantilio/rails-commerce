.PHONY: help start stop restart logs test clean build

# Variáveis
UID := $(shell id -u)
GID := $(shell id -g)

help: ## Mostra esta ajuda
	@echo "Comandos disponíveis:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

start: ## Inicia o ambiente de desenvolvimento
	@echo "Iniciando ambiente em backgroud"
	@export UID=$(UID) GID=$(GID) && docker compose up -d

stop: ## Para o ambiente
	@echo "Parando ambiente..."
	@docker compose down

logs-web: ## Mostra os logs do container web
	@docker compose logs -f web

test: ## Executa os testes
	@echo "Executando testes..."
	@export UID=$(UID) GID=$(GID) && docker compose run --rm test

build: ## Reconstrói as imagens
	@echo "Reconstruindo imagens..."
	@export UID=$(UID) GID=$(GID) && docker compose build --no-cache

status: ## Mostra o status dos containers
	@docker compose ps

shell-web: ## Abre um shell no container web
	@export UID=$(UID) GID=$(GID) && docker compose exec web bash

rails-console: ## Abre o console Rails
	@export UID=$(UID) GID=$(GID) && docker compose exec web rails console

db-setup: ## Configura o banco de dados
	@export UID=$(UID) GID=$(GID) && docker compose exec web rails db:setup

db-migrate: ## Executa as migrações
	@export UID=$(UID) GID=$(GID) && docker compose exec web rails db:migrate

db-seed: ## Executa os seeds
	@export UID=$(UID) GID=$(GID) && docker compose exec web rails db:seed
