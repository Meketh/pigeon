name = pigeon
dkc = docker-compose -p $(name) --project-directory . -f docker/compose.yml
up:
	$(dkc) up -d test
	make deps
	$(dkc) up -d --scale node=2
deps:
	$(dkc) exec test mix do deps.get, deps.compile
	$(dkc) restart
build:
	$(dkc) build
start:
	$(dkc) start
restart:
	$(dkc) restart
stop:
	$(dkc) stop
logs:
	$(dkc) logs -f
test_logs:
	$(dkc) logs -f test
down:
	$(dkc) down
	docker volume prune -f
