# Use slim secure base image
FROM node:18-alpine

# Create app directory
WORKDIR /app

# Copy only dependency files first (best practice)
COPY package*.json ./

# Install production dependencies only
RUN npm ci --only=production

# Now copy application code (safer than COPY . .)
COPY . /app

# Expose port
EXPOSE 3000

# Run as non-root user (fixes Sonar security warning)
USER node

# Start app
CMD ["npm", "start"]
