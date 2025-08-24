# Multi-stage Dockerfile for Flutter Development
FROM ubuntu:22.04 as base

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    wget \
    openjdk-11-jdk \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH=$PATH:$JAVA_HOME/bin

# Install Flutter
ENV FLUTTER_HOME=/opt/flutter
ENV PATH=$PATH:$FLUTTER_HOME/bin:$FLUTTER_HOME/bin/cache/dart-sdk/bin

RUN git clone https://github.com/flutter/flutter.git -b stable $FLUTTER_HOME
RUN flutter doctor

# Install Android SDK
ENV ANDROID_HOME=/opt/android-sdk
ENV PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin

RUN mkdir -p $ANDROID_HOME/cmdline-tools && \
    wget -O android-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip && \
    unzip -q android-tools.zip -d $ANDROID_HOME/cmdline-tools && \
    mv $ANDROID_HOME/cmdline-tools/cmdline-tools $ANDROID_HOME/cmdline-tools/latest && \
    rm android-tools.zip

RUN yes | sdkmanager --licenses && \
    sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.0"

# Development stage
FROM base as development

WORKDIR /app

# Copy pubspec file first for dependency caching
COPY pubspec.yaml ./

# Get dependencies
RUN flutter pub get

# Copy the rest of the application
COPY . .

# Enable web support
RUN flutter config --enable-web

# Expose ports for Flutter web and dev tools
EXPOSE 8080 9000

# Default command for development
CMD ["flutter", "run", "-d", "web-server", "--web-port=8080", "--web-hostname=0.0.0.0", "--dart-define=FLUTTER_WEB_AUTO_DETECT=true"]

# Production stage
FROM base as production

WORKDIR /app

# Copy application files
COPY . .

# Get dependencies
RUN flutter pub get

# Build web application
RUN flutter build web --release --web-renderer html

# Use nginx to serve the built app
FROM nginx:alpine as web-server

COPY --from=production /app/build/web /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]