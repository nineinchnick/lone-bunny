# lone-bunny
A testbed for a standalone Trino instance

## Native image

To build a native image:

```bash
LB_VERSION=$(./mvnw help:evaluate -Dexpression=project.version -q -DforceStdout)
podman build --build-arg LB_VERSION="$LB_VERSION" -t lone-bunny:"$LB_VERSION" .
```

or without a container:
```bash
LB_VERSION=$(./mvnw help:evaluate -Dexpression=project.version -q -DforceStdout)
mvn clean install
native-image --no-fallback -H:+AddAllCharsets -jar target/lone-bunny-"$LB_VERSION"-shaded.jar
```
