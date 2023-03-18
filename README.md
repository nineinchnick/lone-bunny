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
CLASSPATH=$(mvn dependency:build-classpath -Dmdep.includeScope=runtime -Dmdep.outputFile=/dev/stdout -q)
native-image --no-fallback -jar target/lone-bunny-"$LB_VERSION".jar -cp "$CLASSPATH"
```
