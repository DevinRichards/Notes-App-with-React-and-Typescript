# Use the official Node.js image as a base
FROM node:18-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json (or yarn.lock) into the container
COPY package*.json ./

# Install compatible versions of typescript and react-scripts
RUN npm install typescript@4.9.5 react-scripts@5.0.1 --legacy-peer-deps

# Install all other dependencies
RUN npm install --legacy-peer-deps

# Copy the rest of the application code into the container
COPY . .

# Build the application
RUN npm run build

# Use a minimal web server to serve the build output
FROM nginx:alpine

# Copy the build output to the NGINX html directory
COPY --from=0 /app/build /usr/share/nginx/html

# Expose port 80 to the outside world
EXPOSE 80

# Start NGINX
CMD ["nginx", "-g", "daemon off;"]
