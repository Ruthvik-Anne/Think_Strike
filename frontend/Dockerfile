# Frontend Dockerfile (Flutter web build)
FROM cirrusci/flutter:latest AS build

WORKDIR /app
COPY . /app

RUN flutter pub get
RUN flutter build apk

# Nginx to serve Flutter web build
#FROM nginx:alpine
#COPY --from=build /app/build/web /usr/share/nginx/html

#EXPOSE 80
#CMD ["nginx", "-g", "daemon off;"]
