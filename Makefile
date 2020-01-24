REGISTRY=717456749013.dkr.ecr.us-east-1.amazonaws.com
SERVICE=$(notdir $(PWD))
CONTAINER=$(REGISTRY)/$(SERVICE)
COMMIT=`git rev-parse --short HEAD`
BRANCH_TAG=`git rev-parse --abbrev-ref HEAD | sed 's/\//-/g'`
ENVIRONMENT:=staging

release: build
	@make release-tag tag="$(COMMIT)"
	@make release-tag tag="$(ENVIRONMENT)"
	@make release-tag tag="$(ENVIRONMENT).$(BRANCH_TAG).$(COMMIT)"
ifeq ($(ENVIRONMENT), production)
	@make release-tag tag=latest
endif

release-tag:
	docker tag $(SERVICE):$(COMMIT) $(CONTAINER):${tag}
	docker push $(CONTAINER):${tag}

build:
	docker build --rm --force-rm -t $(SERVICE):$(COMMIT) -f Dockerfile .
