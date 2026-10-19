FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app
ARG API_BASE_URL=https://api.aerogreen.vn
COPY . .
RUN flutter pub get
RUN flutter build web --release --dart-define=API_BASE_URL=$API_BASE_URL

FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80
