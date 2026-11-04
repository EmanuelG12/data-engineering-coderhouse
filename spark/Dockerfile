FROM maven:3.9.9-eclipse-temurin-17 AS kafka-connectors

WORKDIR /build
COPY pom.xml .
RUN mvn --batch-mode dependency:copy-dependencies \
    -DincludeScope=runtime \
    -DoutputDirectory=/kafka-jars

FROM apache/spark:3.5.5

USER root
COPY --from=kafka-connectors /kafka-jars/ /opt/spark/jars/
COPY --chown=185:0 job.py /opt/spark/app/job.py
COPY --chown=185:0 driver-pod-template.yaml /opt/spark/app/driver-pod-template.yaml
USER 185