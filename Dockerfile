# Use a multi-stage build to keep the final image small
FROM node:18-alpine AS build

# Set the working directory
WORKDIR /app

# Copy the package.json and package-lock.json for both frontend and backend
COPY notes-app-ui/package*.json ./notes-app-ui/
COPY notes-app-server/package*.json ./notes-app-server/

# Install dependencies for frontend and backend
RUN cd notes-app-ui && npm install
RUN cd notes-app-server && npm install

# Copy the rest of the application code
COPY notes-app-ui/ ./notes-app-ui/
COPY notes-app-server/ ./notes-app-server/

# Build the frontend
RUN cd notes-app-ui && npm run build

# Transpile the backend TypeScript to JavaScript
RUN cd notes-app-server && npm run build

# Use a new, smaller image for the final build
FROM node:18-alpine

# Set the working directory
WORKDIR /app

# Copy the built backend and frontend code
COPY --from=build /app/notes-app-server /app/notes-app-server
COPY --from=build /app/notes-app-ui/build /app/notes-app-ui/build

# Expose the port the app runs on
EXPOSE 3000

# Start the server
CMD ["node", "notes-app-server/src/index.js"]
