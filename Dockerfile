# ---------- Stage 1: build React client ----------
FROM node:20-alpine AS client-build
WORKDIR /app
COPY client ./client
WORKDIR /app/client
RUN if [ -f package-lock.json ]; then \
      npm ci; \
    else \
      npm install; \
    fi && npm run build

# ---------- Stage 2: install server dependencies ----------
FROM node:20-alpine AS server-deps
WORKDIR /app
COPY server/package*.json ./server/
WORKDIR /app/server
RUN if [ -f package-lock.json ]; then \
      npm ci --omit=dev; \
    else \
      npm install --omit=dev; \
    fi

# ---------- Stage 3: runtime ----------
FROM node:20-alpine
WORKDIR /app

# Set production environment
ENV NODE_ENV=production

# Copy server node_modules from deps stage
COPY --from=server-deps /app/server/node_modules ./server/node_modules

# Copy full source
COPY . .

# Copy built React app into server/public 
COPY --from=client-build /app/client/build ./server/public

EXPOSE 3000
WORKDIR /app/server
CMD ["npm", "start"]

