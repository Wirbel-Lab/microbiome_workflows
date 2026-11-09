# Containers for the nextflow workflow

This folder holds the definition files for the containers used in the various
workflows. The containers are then published and made available via the 
Gihub package repository.


### Preparations

Log into the package repository. You will need a classical access token that 
you can generate [here](https://github.com/settings/tokens).

```bash
echo <token> | docker login ghcr.io -u <user.name> --password-stdin
```

### Build a container

To build the container, you will need Docker running on your local machine 
(typically your laptop).

```bash
docker build --platform=linux/amd64 -t <container_name> - < <dockerfile>
```

For example, the container for the classification part of the workflow, 
containing `mOTUs3`, `MetaPhlAn4`, and `Kraken2`, you could build like that:
```bash
docker build --platform=linux/amd64 -t ghcr.io/jakob-wirbel/micromamba-focal-classification - < Dockerfile_classification
```

### Tag the version

To better keep track of changes to the versions of different tools/databases,
we started tagging the versions of each container. By default, the container
will get the "latest" tag, but we would like to have each major release
of the repository reflected in the repo:

```
docker tag ghcr.io/jakob-wirbel/micromamba-focal-classification:latest \
            ghcr.io/jakob-wirbel/micromamba-focal-classification:v1.0
```

### Publish it

Now you are ready to publish the container. You will have to first push it:
```bash
docker push <container_name>:<tag>
```
For example:
```
docker push ghcr.io/jakob-wirbel/micromamba-focal-classification:v1.0
docker push ghcr.io/jakob-wirbel/micromamba-focal-classification:latest
```


Then you have to go to the `Settings` of the package on 
[github.com](github.com/) and make it public.
