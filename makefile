define ips
	docker-compose ps -q | xargs -i docker exec {} hostname -i | xargs echo
endef
cli:
	sh entrypoint.sh "" cli
run:
	sh entrypoint.sh "$$($(call ips))" run
tests_all:
	sh entrypoint.sh "$$($(call ips))" test
tests:
	sh entrypoint.sh "$$($(call ips))" test "--exclude cluster:true"
install:
	rm -rf _build deps
	mix do deps.get, deps.compile
up1:
	docker-compose up -d --scale node=1
up2:
	docker-compose up -d --scale node=2
up3:
	docker-compose up -d --scale node=3
