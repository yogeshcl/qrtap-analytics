# Install dependencies only when needed
FROM node:18-alpine AS deps

# Install required system dependencies
RUN apk add --no-cache libc6-compat openssl

WORKDIR /app

# Copy package files first for efficient caching
COPY package.json yarn.lock ./

# Set yarn timeout to handle slow CPU when using CI/CD
RUN yarn config set network-timeout 300000

# Install dependencies
RUN yarn install --frozen-lockfile

# Rebuild the source code only when needed
FROM node:18-alpine AS builder

WORKDIR /app

# Copy dependencies from previous stage
COPY --from=deps /app/node_modules ./node_modules

# Copy application source code
COPY . .
COPY docker/middleware.js ./src

# Set build arguments
ARG DATABASE_TYPE
ARG BASE_PATH

# Set environment variables
ENV DATABASE_TYPE $DATABASE_TYPE
ENV BASE_PATH $BASE_PATH
ENV NEXT_TELEMETRY_DISABLED 1

# Build application
RUN yarn build-docker

# Production image, copy all the files and run next
FROM node:18-alpine AS runner

WORKDIR /app

# Set environment variables
ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1
ENV PRISMA_CLI_BINARY_TARGETS=linux-musl,linux-glibc

# Create a system user
RUN addgroup --system --gid 1001 nodejs \
    && adduser --system --uid 1001 nextjs

# Install necessary runtime dependencies
RUN apk add --no-cache curl openssl \
    && yarn add npm-run-all dotenv semver prisma@5.17.0

# Copy required application files
COPY --from=builder /app/next.config.js .
COPY --from=builder --chown=nextjs:nodejs /app/public ./public
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/scripts ./scripts

# Copy Next.js build output
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

# Use non-root user
USER nextjs

# Expose application port
EXPOSE 3000

ENV HOSTNAME 0.0.0.0
ENV PORT 3000

# Start application
CMD ["yarn", "start-docker"]
