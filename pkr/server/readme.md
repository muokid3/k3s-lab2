# Nairobi DevSecOps Bootcamp
## K3S Server AMI

Make driven packer configuration for the k3s server

### Usage
```
make
```

#### Dependencies
You must have a file, creds/credentials of the format:

```
[labs]
aws_access_key_id=
aws_secret_access_key=
```

With the appropriate values after the `=` signs. The makefile reads the keys out of here and uses them for docker's environment
