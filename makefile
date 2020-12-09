define ips
	docker-compose ps -q | xargs -i docker exec {} hostname -i | xargs echo
endef
cli:
	sh entrypoint.sh "" cli
run:
	sh entrypoint.sh "$$($(call ips))" run
tests:
	sh entrypoint.sh "$$($(call ips))" test
install:
	mix do deps.get
up: install
	docker-compose up -d --scale node=3
