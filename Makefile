# Generated by usvc-1.13.4
# Feel free to adjust, it will not be overridden

.PHONY: image.build image.run image.test image.push image.pull
.PHONY: create-deploy deploy k8s-shell console watch lint
.PHONY: config-gen abort-on-uncommited-changes copy-mix.lock db.init

SEMAPHORE_EXECUTABLE_UUID?=""
GIT_HASH=$(shell git log --format=format:'%h' -1)
TAG?=$(GIT_HASH)-$(SEMAPHORE_EXECUTABLE_UUID)
REPO=renderedtext/sys2app
IMAGE=$(REPO):$(TAG)
IMAGE_LATEST=$(REPO):latest

HOME_DIR=/home/dev
WORKDIR=$(HOME_DIR)/sys2app
USER=dev
MIX_ENV=dev

CONTAINER_ENV_VARS= \
	-e MIX_ENV=$(MIX_ENV) \

INTERACTIVE_SESSION=\
  -v $$PWD/home_dir:$(HOME_DIR) \
  -v $$PWD:$(WORKDIR) \
  --rm \
  --workdir=$(WORKDIR) \
  --user=$(USER) \
  -it renderedtext/elixir-dev:1.5.1-v2

CMD?=/bin/bash

console:
	docker run --network=host $(CONTAINER_ENV_VARS) $(INTERACTIVE_SESSION) $(CMD)

image.build:
	docker build --cache-from $(IMAGE_LATEST) -t $(IMAGE) .
	docker tag $(IMAGE) $(IMAGE_LATEST)

image.run: image.build
	docker run -p 4000:4000 -it $(IMAGE)

# Container litens on different port
# (so that container and 'mix run' can run together)
image.test: image.build
	docker run --rm --name sys2app -p 4004:4000 -d $(IMAGE)
	# run some tests...
	docker kill sys2app

create-deploy: abort-on-uncommited-changes image.push config-gen
	kubectl create -f deploy.yml
	kubectl get svc/sys2app

deploy: abort-on-uncommited-changes image.push config-gen
	kubectl apply -f deploy.yml
	kubectl get svc/sys2app

k8s-shell:
	$(eval pod_name=$(shell kubectl get po -l app=cluster-portal -o jsonpath={.items[*].metadata.name}))
	kubectl exec -it $(pod_name) -- /bin/bash

watch:
	docker run --network=host $(CONTAINER_ENV_VARS) $(INTERACTIVE_SESSION) \
         mix do deps.get, test.watch

lint:
	$(MAKE) console CMD="mix do credo"

lint-root:
	$(MAKE) console USER=root CMD="mix do local.hex --force, local.rebar --force, deps.get, credo"

postgres.run:
	docker run -d --rm --name db --network=host postgres:9.6
	@echo "\nWaiting for DB to become operational"
	sleep 5
	$(MAKE) db.init

db.init:
	$(MAKE) console MIX_ENV=$(MIX_ENV) USER=$(USER) CMD="mix do ecto.create, ecto.migrate"
	@echo "\nDatabase '$(DB_NAME)' created and migrated."
	@echo "\nConnect with: 'psql -h localhost -U postgres $(DB_NAME)'"

image.push: image.build
	docker push $(IMAGE)
	docker push $(IMAGE_LATEST)

image.pull:
	docker pull $(IMAGE)
	docker pull $(IMAGE_LATEST)

usvc.install:
	mix archive.install http://usvc.tools.renderedtext.com/usvc-1.13.4.ez --force

config-gen:
	mix usvc.cfg_gen $(TAG)

abort-on-uncommited-changes:
	git diff-index --quiet HEAD --
