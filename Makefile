all: run

run: .atom.cid

build:
	docker build . -t `cat TAG`

.atom.cid: clean ATOM_HOME
	$(eval TMP := $(shell mktemp -d --suffix=DOCKERTMP))
	$(eval ATOM_HOME := $(shell cat ATOM_HOME))
	$(eval WORKDIR := $(shell cat WORKDIR))
	docker run -d \
		--cidfile=.atom.cid \
		-v /dev/shm:/dev/shm \
		-v ${ATOM_HOME}:/home/atom/.atom \
		-v ${WORKDIR}:/home/atom/workdir \
		-v /tmp/.X11-unix/:/tmp/.X11-unix/ \
		-e DISPLAY \
	  `cat TAG`

logs:
	docker logs -f `cat .atom.cid`

kill:
	-@docker kill `cat .atom.cid`

rm-image:
	-@docker rm `cat .atom.cid`
	-@rm .atom.cid

rm: kill rm-image

clean: rm

enter:
	docker exec -i -t `cat .atom.cid` /bin/bash

ATOM_HOME:
	@while [ -z "$$ATOM_HOME" ]; do \
		read -r -p "Enter the path to the Atom home you wish to associate with this container [ATOM_HOME]: " ATOM_HOME; echo "$$ATOM_HOME">>ATOM_HOME; cat ATOM_HOME; \
	done ;

WORKDIR:
	@while [ -z "$$WORKDIR" ]; do \
		read -r -p "Enter the path to the directory to work with in this container [WORKDIR]: " WORKDIR; echo "$$WORKDIR">>WORKDIR; cat WORKDIR; \
	done ;
