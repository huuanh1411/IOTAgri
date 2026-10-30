FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app
COPY . .
RUN flutter pub get
# Bundle CanvasKit so browser tests do not depend on Google's renderer CDN.
RUN flutter build web --release --no-web-resources-cdn --dart-define=API_BASE_URL=
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
