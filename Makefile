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
	@echo "  make up          Start containers"
	@echo "  make down        Stop containers"
	@echo "  make restart     Restart containers"
	@echo "  make logs        Tail all container logs"
	@echo "  make db          Open psql in database container"
	@echo "  make reset-db    Delete DB volume and recreate from init SQL"
	@echo ""
	@echo "App:"
	@echo "  make restore     Restore NuGet packages"
	@echo "  make build       Build solution"
	@echo "  make clean       Clean solution"
	@echo "  make run         Run web app locally"
	@echo ""
	@echo "Verification:"
	@echo "  make db-check    List schemas and tables"
	@echo ""

up:
	docker compose up -d

down:
	docker compose down --remove-orphans

restart:
	docker compose down --remove-orphans
	docker compose up -d

logs:
	docker compose logs -f

db:
	docker exec -it $(DB_CONTAINER) psql -U $(DB_USER) -d $(DB_NAME)

reset-db:
	docker compose down -v --remove-orphans
	docker compose up -d

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