NAME=muoki

default: fmt pack

name: 
	@echo "name=${NAME}"

pack:
	time -p docker container run -it --rm \
		--env AWS_PROFILE=labs \
		-v $$PWD/../../creds:/root/.aws \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v $$PWD:/$$(basename $$PWD) \
		--hostname "$$(basename $$PWD)" \
		--name "$$(basename $$PWD)" \
		-w /$$(basename $$PWD) \
		--entrypoint="/usr/local/bin/packer" \
		bryandollery/terraform-packer-aws-alpine:14 build -var="name=${NAME}" packer.pkr.hcl

fmt:
	docker container run -it --rm \
		-v $$PWD/../../creds:/root/.aws \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v $$PWD:/$$(basename $$PWD) \
		--hostname "$$(basename $$PWD)" \
		--name "$$(basename $$PWD)" \
		-w /$$(basename $$PWD) \
		--entrypoint="/usr/local/bin/packer" \
		bryandollery/terraform-packer-aws-alpine:14 fmt -var="name=${NAME}" packer.pkr.hcl
