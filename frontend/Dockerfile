FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app
ARG API_BASE_URL=https://api.aerogreen.vn
ARG GOOGLE_WEB_CLIENT_ID
ARG GOOGLE_ANDROID_SERVER_CLIENT_ID
COPY pubspec.yaml pubspec.lock ./
RUN --mount=type=cache,target=/root/.pub-cache flutter pub get
COPY . .
RUN --mount=type=cache,target=/root/.pub-cache flutter build web --release --pwa-strategy=none --dart-define=API_BASE_URL=$API_BASE_URL --dart-define=GOOGLE_WEB_CLIENT_ID=$GOOGLE_WEB_CLIENT_ID --dart-define=GOOGLE_ANDROID_SERVER_CLIENT_ID=$GOOGLE_ANDROID_SERVER_CLIENT_ID
RUN set -eux; \
    bundle_hash="$(sha256sum build/web/main.dart.js | cut -c1-12)"; \
    cp build/web/main.dart.js "build/web/main.${bundle_hash}.dart.js"; \
    sed -i "s/main\\.dart\\.js/main.${bundle_hash}.dart.js/g" build/web/flutter_bootstrap.js; \
    grep -q "main.${bundle_hash}.dart.js" build/web/flutter_bootstrap.js

FROM nginx:alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build/web /usr/share/nginx/html
RUN nginx -t
EXPOSE 80
