FROM node:22-alpine AS base

WORKDIR /app

COPY package.json package-lock.json ./

FROM base AS deps
ARG NODE_ENV=production
RUN if [ "$NODE_ENV" = "production" ]; then npm ci --omit=dev; else npm install; fi

FROM deps AS builder
ARG NODE_ENV=production
COPY . .

RUN if [ "$NODE_ENV" = "production" ]; then npm run build; fi

FROM node:22-alpine AS runner
WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY --from=builder /app .

EXPOSE 3000

CMD ["sh", "-c", "if [ \"$NODE_ENV\" = \"development\" ]; then npm run dev; else npm run start; fi"]