# Use official Maven base image with JDK 17
FROM maven:3.9.6-eclipse-temurin-17 AS builder

# Set working directory
WORKDIR /app

# Copy the Maven project into the image
COPY . .

# Optional: Speed up builds by caching dependencies
RUN mvn dependency:go-offline

# Build the plugin (skip tests for speed; remove `-DskipTests` if you want to run them)
RUN mvn clean install -DskipTests

# --------------------------------------------------------------------------------
# Stage 2: Create minimal runtime image if needed (e.g. to run integration tests)
# You can stop at the first stage if you're only building plugin `.hpi` files.
# --------------------------------------------------------------------------------

FROM eclipse-temurin:17-jdk AS runtime

# Set working directory
WORKDIR /jenkins-plugin

# Copy built HPI files from builder
COPY --from=builder /app/target/*.hpi ./plugin.hpi

# (Optional) Run or test the plugin in a Jenkins container or with Jenkins CLI

# Default command: show plugin file
CMD ["ls", "-lh", "plugin.hpi"]
