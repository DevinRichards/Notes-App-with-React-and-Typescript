# ---- Build the frontend ----
# Use the official Node.js image as a base
FROM node:18-alpine as build-frontend

# Set the working directory inside the container
WORKDIR /app

# Copy the frontend package.json and package-lock.json (or yarn.lock) into the container
COPY notes-app-ui/package*.json ./notes-app-ui/

# Install frontend dependencies
RUN cd notes-app-ui && npm install

# Copy the rest of the frontend application code into the container
COPY notes-app-ui ./notes-app-ui

# Build the frontend application
RUN cd notes-app-ui && npm run build

# ---- Build the backend ----
# Use the official Node.js image as a base
FROM node:18-alpine as build-backend

# Set the working directory inside the container
WORKDIR /app

# Copy the backend package.json and package-lock.json (or yarn.lock) into the container
COPY notes-app-server/package*.json ./notes-app-server/

# Install backend dependencies
RUN cd notes-app-server && npm install

# Copy the rest of the backend application code into the container
COPY notes-app-server ./notes-app-server

# ---- Create the final image ----
FROM node:18-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy the built frontend files to the final image
COPY --from=build-frontend /app/notes-app-ui/build ./notes-app-ui/build

# Copy the backend files to the final image
COPY --from=build-backend /app/notes-app-server ./notes-app-server

# Set environment variables if needed
ENV NODE_ENV=production

# Expose the ports your applications run on
EXPOSE 3000 5000

# Start the backend server
CMD ["node", "notes-app-server/src/index.js"]
