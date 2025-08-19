# # #---------- Single Stage ----------
# # FROM openjdk:21-jdk
# # WORKDIR /app
# # COPY target/customerapp.jar /app/customerapp.jar
# # EXPOSE 9000
# # ENTRYPOINT ["java", "-jar", "customerapp.jar"]



# # ---------- Multi Stage ----------
# # ---------- Build Stage ----------
# FROM maven:3.9-eclipse-temurin-21 AS build
# WORKDIR /app

# # Copy pom.xml and download dependencies first (for better caching)
# COPY pom.xml .
# RUN mvn dependency:go-offline -B

# # Copy source code and build
# COPY src ./src
# RUN mvn clean package -DskipTests

# # ---------- Runtime Stage ----------
# FROM openjdk:21-jdk
# WORKDIR /app

# # Copy only the JAR from build stage
# COPY --from=build /app/target/customerapp.jar /app/customerapp.jar

# EXPOSE 9000

# ENTRYPOINT ["java", "-jar", "customerapp.jar"]






# ----------------------------------------------------------------------

# #---------- Single Stage ----------
# FROM openjdk:21-jdk
# WORKDIR /app
# COPY target/customerapp.jar /app/customerapp.jar
# EXPOSE 9000
# ENTRYPOINT ["java", "-jar", "customerapp.jar"]



# ---------- Multi Stage ----------
# ---------- Build Stage ----------
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app

# Copy pom.xml and download dependencies first (for better caching)
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source code and build
COPY src ./src
RUN mvn clean package -DskipTests

# ---------- Runtime Stage ----------
# Stage 2 - Create the final image with the built application
# Alpine version of the JRE is used for a smaller image size
# Use a minimal JRE image to run the application
FROM eclipse-temurin:21-jre-alpine

# Run as a non-root user for security
RUN addgroup --system spring && adduser --system --ingroup spring spring

WORKDIR /app

# Copy only the JAR from build stage
# COPY --from=build /app/target/customerapp.jar /app/customerapp.jar
COPY --from=build /app/target/*.jar app.jar

# Change ownership of the JAR file to the non-root user
RUN chown spring:spring app.jar

# Switch to the non-root user
USER spring:spring

EXPOSE 9000

ENTRYPOINT ["java", "-jar", "customerapp.jar"]




