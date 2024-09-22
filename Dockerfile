# Stage 1: Build stage for SonarQube Scanner
FROM sonarsource/sonar-scanner-cli:4.6 as sonar-scanner-builder

# Stage 2: Final image
FROM ubuntu:20.04

# Set environment variable to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    lsb-release \
    jq \
    git \
    wget \
    unzip \
    openjdk-17-jre-headless \
    && rm -rf /var/lib/apt/lists/*

# Copy SonarQube Scanner from the build stage
COPY --from=sonar-scanner-builder /opt/sonar-scanner /opt/sonar-scanner
RUN ln -s /opt/sonar-scanner/bin/sonar-scanner /usr/local/bin/sonar-scanner

# Set environment variables for SonarQube Scanner
ENV SONAR_SCANNER_HOME=/opt/sonar-scanner
ENV PATH=$PATH:/opt/sonar-scanner/bin

# Set the default command to sleep
CMD ["sleep", "9999999"]
