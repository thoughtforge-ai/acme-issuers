CHART_REPO := http://jenkins-x-chartmuseum:8080
NAME := acme
OS := $(shell uname)
VERSION := 0.1.1
KNATIVE_VERSION := 0.12.1

CHARTMUSEUM_CREDS_USR := $(shell cat /builder/home/basic-auth-user.json)
CHARTMUSEUM_CREDS_PSW := $(shell cat /builder/home/basic-auth-pass.json)

init:
	helm init --client-only

setup: init
	helm repo add jenkinsxio http://chartmuseum.jenkins-x.io

build: clean setup
	helm lint acme

install: clean build
	helm upgrade ${NAME} acme --install

upgrade: clean build
	helm upgrade ${NAME} acme --install

delete:
	helm delete --purge ${NAME} acme

clean:
	rm -rf acme/charts
	rm -rf acme/${NAME}*.tgz
	rm -rf acme/requirements.lock

release: clean build
ifeq ($(OS),Darwin)
	sed -i "" -e "s/version:.*/version: $(VERSION)/" acme/Chart.yaml

else ifeq ($(OS),Linux)
	sed -i -e "s/version:.*/version: $(VERSION)/" acme/Chart.yaml
else
	exit -1
endif
	helm package acme
	curl --fail -u $(CHARTMUSEUM_CREDS_USR):$(CHARTMUSEUM_CREDS_PSW) --data-binary "@$(NAME)-$(VERSION).tgz" $(CHART_REPO)/api/charts
	rm -rf ${NAME}*.tgz


test:
	cd tests && go test -v

test-regen:
	cd tests && export HELM_UNIT_REGENERATE_EXPECTED=true && go test -v