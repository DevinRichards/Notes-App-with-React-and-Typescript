# ---- Build the frontend ----
    FROM node:18-alpine as build-frontend

    WORKDIR /app
    
    # Install frontend dependencies
    COPY notes-app-ui/package*.json ./notes-app-ui/
    RUN cd notes-app-ui && npm install --legacy-peer-deps
    
    # Build the frontend
    COPY notes-app-ui ./notes-app-ui
    RUN cd notes-app-ui && npm run build
    
    # ---- Build the backend ----
    FROM node:18-alpine as build-backend
    
    WORKDIR /app
    
    # Install backend dependencies
    COPY notes-app-server/package*.json ./notes-app-server/
    RUN cd notes-app-server && npm install --legacy-peer-deps
    
    # Generate Prisma Client
    COPY notes-app-server/prisma ./notes-app-server/prisma
    RUN cd notes-app-server && npx prisma generate
    
    # Compile TypeScript to JavaScript
    COPY notes-app-server ./notes-app-server
    RUN cd notes-app-server && npm run build
    
    # ---- Create the final image ----
    FROM node:18-alpine
    
    WORKDIR /app
    
    # Copy the built frontend files to the final image
    COPY --from=build-frontend /app/notes-app-ui/build ./notes-app-ui/build
    
    # Copy the backend files and dependencies to the final image
    COPY --from=build-backend /app/notes-app-server/dist ./notes-app-server/dist
    COPY --from=build-backend /app/notes-app-server/node_modules ./notes-app-server/node_modules
    COPY --from=build-backend /app/notes-app-server/prisma ./notes-app-server/prisma
    
    # Verify the copied files
    RUN ls -al ./notes-app-server/dist
    RUN ls -al ./notes-app-server/node_modules
    RUN ls -al ./notes-app-server/prisma
    
    ENV NODE_ENV=production
    
    EXPOSE 3000 5000
    
    CMD ["node", "notes-app-server/dist/index.js"]
    