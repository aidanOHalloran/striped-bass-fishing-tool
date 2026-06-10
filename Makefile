.DEFAULT_GOAL := help

SOLUTION = striped-bass-fishing-tool.slnx
WEB_PROJECT = src/StripedBassFishingTool.Web/StripedBassFishingTool.Web.csproj
DB_CONTAINER = striped-bass-fishing-tool-db
DB_USER = stripedbassuser
DB_NAME = stripedbassfishingtool

help:
	@echo ""
	@echo "Striped Bass Fishing Tool"
	@echo "========================="
	@echo ""
	@echo "Docker:"
	@echo "  make up             Start containers"
	@echo "  make down           Stop containers and remove orphan containers"
	@echo "  make restart        Restart containers without rebuilding images"
	@echo "  make rebuild        Rebuild Docker images and restart containers"
	@echo "  make rebuild-clean  Rebuild Docker images without cache and restart"
	@echo "  make logs           Tail all container logs"
	@echo "  make db             Open psql in the PostgreSQL container"
	@echo "  make reset-db       Delete DB volume, recreate schema from init SQL, then run seed files"
	@echo "  make reset-all      Delete containers, volumes, local images, rebuild, and restart"
	@echo ""
	@echo "Database:"
	@echo "  make seed           Run durable seed files from db/seed in order"
	@echo "                     010_reference_seed.sql"
	@echo "                     020_body_of_water_seed.sql"
	@echo "                     100_knowledge_entries_seed.sql"
	@echo ""
	@echo "App:"
	@echo "  make restore        Restore NuGet packages locally"
	@echo "  make build          Build solution locally"
	@echo "  make clean          Clean solution locally"
	@echo "  make run            Run web app locally outside Docker"
	@echo ""
	@echo "Verification:"
	@echo "  make db-check       List database schemas and app tables"
	@echo ""

up:
	docker compose up -d

down:
	docker compose down --remove-orphans

restart:
	docker compose down --remove-orphans
	docker compose up -d

rebuild:
	docker compose down --remove-orphans
	docker compose up -d --build

rebuild-clean:
	docker compose down --remove-orphans
	docker compose build --no-cache
	docker compose up -d

logs:
	docker compose logs -f

db:
	docker exec -it $(DB_CONTAINER) psql -U $(DB_USER) -d $(DB_NAME)

seed:
	docker exec -i $(DB_CONTAINER) psql -v ON_ERROR_STOP=1 -U $(DB_USER) -d $(DB_NAME) < db/seed/010_reference_seed.sql
	docker exec -i $(DB_CONTAINER) psql -v ON_ERROR_STOP=1 -U $(DB_USER) -d $(DB_NAME) < db/seed/020_body_of_water_seed.sql
	docker exec -i $(DB_CONTAINER) psql -v ON_ERROR_STOP=1 -U $(DB_USER) -d $(DB_NAME) < db/seed/100_knowledge_entries_seed.sql

reset-db:
	docker compose down -v --remove-orphans
	docker compose up -d --build
	$(MAKE) wait-db
	$(MAKE) seed

reset-all:
	docker compose down -v --remove-orphans --rmi local
	docker compose up -d --build
	$(MAKE) wait-db
	$(MAKE) seed

restore:
	dotnet restore $(SOLUTION)

build:
	dotnet build $(SOLUTION)

clean:
	dotnet clean $(SOLUTION)

run:
	dotnet run --project $(WEB_PROJECT)

db-check:
	docker exec -it $(DB_CONTAINER) psql -U $(DB_USER) -d $(DB_NAME) -c "\dn"
	docker exec -it $(DB_CONTAINER) psql -U $(DB_USER) -d $(DB_NAME) -c "\dt stripedbassfishingtool.*"

wait-db:
	powershell -NoProfile -Command "while ((docker exec $(DB_CONTAINER) pg_isready -U $(DB_USER) -d $(DB_NAME)) -notmatch 'accepting connections') { Start-Sleep -Seconds 1 }"

