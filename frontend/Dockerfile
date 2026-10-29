FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app
ARG API_BASE_URL=https://api.aerogreen.vn
ARG GOOGLE_WEB_CLIENT_ID
ARG GOOGLE_ANDROID_SERVER_CLIENT_ID
COPY . .
RUN flutter pub get
RUN flutter build web --release --dart-define=API_BASE_URL=$API_BASE_URL --dart-define=GOOGLE_WEB_CLIENT_ID=$GOOGLE_WEB_CLIENT_ID --dart-define=GOOGLE_ANDROID_SERVER_CLIENT_ID=$GOOGLE_ANDROID_SERVER_CLIENT_ID

FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80
