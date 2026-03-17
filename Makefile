ENV_FILE := .env
EXCALIDRAW_COMPOSE := docker compose --env-file $(ENV_FILE) -f docks/excalidraw/docker-compose.yml
DOZZLE_COMPOSE := docker compose --env-file $(ENV_FILE) -f docks/dozzle/docker-compose.yml
FILEBROWSER_COMPOSE := docker compose --env-file $(ENV_FILE) -f docks/filebrowser/docker-compose.yml
GITEA_COMPOSE := docker compose --env-file $(ENV_FILE) -f docks/gitea/docker-compose.yml
BESZEL_COMPOSE := docker compose --env-file $(ENV_FILE) -f docks/beszel/docker-compose.yml

.PHONY: up-all down-all logs up-excalidraw up-dozzle up-filebrowser up-gitea up-beszel up-beszel-agent down-excalidraw down-dozzle down-filebrowser down-gitea down-beszel down-beszel-agent

up-all:
	$(EXCALIDRAW_COMPOSE) up -d
	$(DOZZLE_COMPOSE) up -d
	$(FILEBROWSER_COMPOSE) up -d
	$(GITEA_COMPOSE) up -d
	$(BESZEL_COMPOSE) up -d

up-excalidraw:
	$(EXCALIDRAW_COMPOSE) up -d

up-dozzle:
	$(DOZZLE_COMPOSE) up -d

up-filebrowser:
	$(FILEBROWSER_COMPOSE) up -d

up-gitea:
	$(GITEA_COMPOSE) up -d

up-beszel:
	$(BESZEL_COMPOSE) up -d

up-beszel-agent:
	$(BESZEL_COMPOSE) --profile agent up -d

down-all:
	$(BESZEL_COMPOSE) down
	$(GITEA_COMPOSE) down
	$(FILEBROWSER_COMPOSE) down
	$(DOZZLE_COMPOSE) down
	$(EXCALIDRAW_COMPOSE) down

down-excalidraw:
	$(EXCALIDRAW_COMPOSE) down

down-dozzle:
	$(DOZZLE_COMPOSE) down

down-filebrowser:
	$(FILEBROWSER_COMPOSE) down

down-gitea:
	$(GITEA_COMPOSE) down

down-beszel:
	$(BESZEL_COMPOSE) down

down-beszel-agent:
	$(BESZEL_COMPOSE) --profile agent down

logs:
	$(EXCALIDRAW_COMPOSE) logs --tail=50
	$(DOZZLE_COMPOSE) logs --tail=50
	$(FILEBROWSER_COMPOSE) logs --tail=50
	$(GITEA_COMPOSE) logs --tail=50
	$(BESZEL_COMPOSE) logs --tail=50
