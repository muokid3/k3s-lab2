# Chaos Engineers Labs - K3S cluster

This repo builds a k3s cluster with one control-plane node and 3 worker-nodes in an autoscaling group. It also creates a bastion for controling the kubernetes cluster.

Directories:

- *creds* - AWS Credentials
- *pkr* - packer AMI creator
- *tf* - terraform infra

Usage:

The directories each contain a Makefile that can be used with standard GNU make and variants thereof. You'll have to read the Makefiles to see what they do, but they use docker to provide the tooling they to do their work.

The only tools you need installed to use this repo are docker and make, and even make is optional if you want to run the docker commands manually.

You'll need to add a credentials file in the creds dir that looks like this:

```conf
[labs]
aws_access_key_id=AKIAAAAAAAAA00AAA0AA
aws_secret_access_key=9ajdf9j34243lasdf898ufa/a4sklajfd
```

