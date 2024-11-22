FROM openjdk:17-jdk-alpine
ARG JAR_FILE=foyer/target/*.jar
COPY ${JAR_FILE} app.jar
ENTRYPOINT ["java","-jar","/app.jar"]