DOCKER_USERNAME ?= diptanu
APPLICATION_NAME ?= indexify
current_dir = $(shell pwd)
src_py_dir = $(shell pwd)/src_py

build:
	cargo build

build-release:
	cargo build --release

clean:
	cargo clean

build-container:
	docker build --tag ${DOCKER_USERNAME}/${APPLICATION_NAME} .
	docker image prune --force --filter label=stage=builder

entity:
	sea-orm-cli generate entity -o src/entity --with-serde both --date-time-crate time

local-dev:
	docker stop indexify-local-postgres || true
	docker run --rm -p 5432:5432 --name=indexify-local-postgres -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=indexify -d postgres
	timeout 90s bash -c "until docker exec indexify-local-postgres pg_isready ; do sleep 5 ; done"
	cargo install sea-orm-cli
	DATABASE_URL=postgres://postgres:postgres@localhost:5432/indexify
	sea-orm-cli migrate up
	docker stop indexixify-local-qdrant || true
	docker run --rm -p 6334:6334 --name=indexixify-local-qdrant -d -e QDRANT__SERVICE__GRPC_PORT="6334"  qdrant/qdrant:v1.1.1

test:
	run_tests.sh

.PHONY: do_script
install-py:
	$(MAKE) -C ${src_py_dir} install_deps.sh

shell:
	docker run --net host -v ${current_dir}:/indexify-build/indexify -it diptanu/indexify-build /bin/bash

