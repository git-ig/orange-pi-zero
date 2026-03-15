ENV_FILE := .env
DASHBOARD_COMPOSE := docker compose --env-file $(ENV_FILE) -f docks/dashboard/docker-compose.yml
FILEBROWSER_COMPOSE := docker compose --env-file $(ENV_FILE) -f docks/filebrowser/docker-compose.yml
GITEA_COMPOSE := docker compose --env-file $(ENV_FILE) -f docks/gitea/docker-compose.yml
BESZEL_COMPOSE := docker compose --env-file $(ENV_FILE) -f docks/beszel/docker-compose.yml

.PHONY: up-all down-all logs up-dashboard up-filebrowser up-gitea up-beszel down-dashboard down-filebrowser down-gitea down-beszel

up-all:
	$(DASHBOARD_COMPOSE) up -d
	$(FILEBROWSER_COMPOSE) up -d
	$(GITEA_COMPOSE) up -d
	$(BESZEL_COMPOSE) up -d

up-dashboard:
	$(DASHBOARD_COMPOSE) up -d

up-filebrowser:
	$(FILEBROWSER_COMPOSE) up -d

up-gitea:
	$(GITEA_COMPOSE) up -d

up-beszel:
	$(BESZEL_COMPOSE) up -d

down-all:
	$(BESZEL_COMPOSE) down
	$(GITEA_COMPOSE) down
	$(FILEBROWSER_COMPOSE) down
	$(DASHBOARD_COMPOSE) down

down-dashboard:
	$(DASHBOARD_COMPOSE) down

down-filebrowser:
	$(FILEBROWSER_COMPOSE) down

down-gitea:
	$(GITEA_COMPOSE) down

down-beszel:
	$(BESZEL_COMPOSE) down

logs:
	$(DASHBOARD_COMPOSE) logs --tail=50
	$(FILEBROWSER_COMPOSE) logs --tail=50
	$(GITEA_COMPOSE) logs --tail=50
	$(BESZEL_COMPOSE) logs --tail=50
