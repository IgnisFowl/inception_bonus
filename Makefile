COMPOSE_FILE    = srcs/docker-compose.yml
DATA_DIR        = /home/aarie-c2/data

all: create_dirs
	docker compose -f $(COMPOSE_FILE) up -d --build

create_dirs:
	@mkdir -p $(DATA_DIR)/mariadb
	@mkdir -p $(DATA_DIR)/wordpress
	@mkdir -p $(DATA_DIR)/portainer  # 💡 Garante que a pasta nasça no host

down:
	docker compose -f $(COMPOSE_FILE) down

clean: down
	docker compose -f $(COMPOSE_FILE) down -v
	@sudo rm -rf $(DATA_DIR)

fclean: clean
	docker system prune -af

re: fclean all

logs:
	docker compose -f $(COMPOSE_FILE) logs -f

status:
	docker compose -f $(COMPOSE_FILE) ps

.PHONY: all create_dirs down clean fclean re logs status