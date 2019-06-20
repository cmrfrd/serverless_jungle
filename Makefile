SHELL=/bin/bash
CTL_COMMAND="bash"

REPO=$(shell basename `git rev-parse --show-toplevel`)
TIMESTAMP=tmp-$(shell date +%s )

MINIKUBE?=minikube
DOCKER?=docker
CURL?=curl

install-minikube:
	$(CURL) -Lo minikube https://storage.googleapis.com/minikube/releases/v1.1.1/minikube-$$(uname | tr A-Z a-z)-amd64 && chmod +x minikube && mv minikube /usr/local/bin/

## Star tminikube with minimal resoruces
start:
	$(MINIKUBE) start         \
		--cpus 6          \
		--memory 8096     \
		--profile $(REPO)

## Stop minikube in current profile
minikube-%:
	$(MINIKUBE) $* --profile $(REPO)
ssh:
	$(MINIKUBE) ssh --profile $(REPO) $(COMMAND)
shell: COMMAND = "bash"
shell: ssh

## Mount background daemon once
mount:
	$(eval MINIKUBE_MOUNTS=$(shell ps | grep $(MINIKUBE) | grep mount | wc -l))
	@if [[ $(MINIKUBE_MOUNTS) < 2 ]]; then \
		$(MINIKUBE) mount --profile $(REPO) $$(pwd):/mnt > /dev/null 2>&1 & \
	fi;

ctl-build:
	@$(DOCKER) build -t $(REPO)-ctl -f dockerfiles/Dockerfile.ctl dockerfiles/

ctl-shell:
	@$(MINIKUBE) docker-env --profile $(REPO) > minikube-env.sh
	@docker run \
		 --rm \
		 --net host \
		 -e HOME=$$HOME \
		 -v $$(pwd):$$HOME/mnt/ \
		 -v ~/.kube:$$HOME/.kube:z \
		 -v ~/.helm:$$HOME/.helm:z \
		 -v ~/.minikube:$$HOME/.minikube:z \
		 -v /var/run/docker.sock:/var/run/docker.sock:z \
		 -w $$HOME/mnt/ \
		 -it $(REPO)-ctl \
		 bash -c "source minikube-env.sh && $(CTL_COMMAND)"

install-knative: CTL_COMMAND=kubectl kn install
install-knative: ctl-shell

install-kaniko: CTL_COMMAND=kubectl apply -f https://raw.githubusercontent.com/knative/build-templates/master/kaniko/kaniko.yaml
install-kaniko: ctl-shell

install: install-knative install-kaniko

local:
   # @eval $$(minikube docker-env);\
   docker image build -t $(REPO):$(TIMESTAMP) -f Dockerfile .;
   kubectl set image deployment $(REPO) *=$(REPO):$(TIMESTAMP)
