# Stage 1: Build
FROM node:20-alpine AS build
WORKDIR /app

# Use wildcards to be safe
COPY medmatch-ui/package*.json ./
RUN npm install

# Copy everything from the medmatch-ui folder
COPY medmatch-ui/ .

RUN npm run build -- --configuration production

# Stage 2: Serve
FROM nginx:stable-alpine

# Match the output path from your angular.json
COPY --from=build /app/dist/medmatch-ui/browser /usr/share/nginx/html

# This was the line that failed - it looks for nginx.conf in ./frontend/
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]