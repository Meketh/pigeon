name = pigeon
ips = $($(dkc) ps -q | xargs -i docker exec {} hostname -i | xargs echo)
dkc = docker-compose -p $(name) --project-directory . -f docker/compose.yml
up: install build
	$(dkc) up -d --scale node=3
install:
	mix do deps.get, deps.compile
build:
	$(dkc) build
start:
	$(dkc) start
restart:
	$(dkc) restart
stop:
	$(dkc) stop
logs:
	$(dkc) logs -f --tail 10
down:
	$(dkc) down
	docker volume prune -f
ips:
	$(call ips)
run:
	sh docker/entrypoint.sh "$$($(call ips))" run
tests:
	sh docker/entrypoint.sh "$$($(call ips))" test

define ips
	$(dkc) ps -q | xargs -i docker exec {} hostname -i | xargs echo
endef
