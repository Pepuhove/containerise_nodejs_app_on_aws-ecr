# Stage 1: Build Stage
FROM node:22-slim AS build
WORKDIR /app

# Copy package.json and package-lock.json first for caching layer optimization
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy application source code
COPY . .

# Expose the application port
EXPOSE 3000

# Command to run the application
CMD ["npm", "start"]

