FROM node:18-slim

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json (if available)
COPY package*.json ./

# Install dependencies in a separate layer for caching
RUN npm ci --only=production

# Copy the application source code
COPY . ./

# Expose the port
EXPOSE 8080

# Start the application
CMD ["npm", "start"]
