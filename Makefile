ENV_FILE := .env
EXCALIDRAW_COMPOSE := docker compose --env-file $(ENV_FILE) -f docks/excalidraw/docker-compose.yml
FILEBROWSER_COMPOSE := docker compose --env-file $(ENV_FILE) -f docks/filebrowser/docker-compose.yml
GITEA_COMPOSE := docker compose --env-file $(ENV_FILE) -f docks/gitea/docker-compose.yml
BESZEL_COMPOSE := docker compose --env-file $(ENV_FILE) -f docks/beszel/docker-compose.yml

.PHONY: up-all down-all logs up-excalidraw up-filebrowser up-gitea up-beszel down-excalidraw down-filebrowser down-gitea down-beszel

up-all:
	$(EXCALIDRAW_COMPOSE) up -d
	$(FILEBROWSER_COMPOSE) up -d
	$(GITEA_COMPOSE) up -d
	$(BESZEL_COMPOSE) up -d

up-excalidraw:
	$(EXCALIDRAW_COMPOSE) up -d

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
	$(EXCALIDRAW_COMPOSE) down

down-excalidraw:
	$(EXCALIDRAW_COMPOSE) down

down-filebrowser:
	$(FILEBROWSER_COMPOSE) down

down-gitea:
	$(GITEA_COMPOSE) down

down-beszel:
	$(BESZEL_COMPOSE) down

logs:
	$(EXCALIDRAW_COMPOSE) logs --tail=50
	$(FILEBROWSER_COMPOSE) logs --tail=50
	$(GITEA_COMPOSE) logs --tail=50
	$(BESZEL_COMPOSE) logs --tail=50
