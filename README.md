# debos-docker

Docker container for ['debos' tool](https://github.com/go-debos/debos).

## Installation
```
docker pull go-debos/debos-docker
```

Debos needs virtualization to be enabled on the host and shared with the container.

Check that `kvm` is enabled by running ```ls /dev/kvm```

## Usage
To build `recipe.yaml`:
```
cd <PATH_TO_RECIPE_DIR>
docker run --rm --device /dev/kvm --group-add $(getent group kvm | cut -d: -f3) -w /recipes -u $(id -u) -i -v $(pwd):/recipes -t go-debos/debos-docker debos recipe.yaml
```
