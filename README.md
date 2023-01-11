# lone-bunny
A testbed for a standalone Trino instance

## Native image

To build a native image:

```bash
podman build --build-arg LB_VERSION=0.1-SNAPSHOT -t lone-bunny:0.1-SNAPSHOT .
```
