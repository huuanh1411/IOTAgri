FROM mcr.microsoft.com/playwright:v1.64.1-noble
WORKDIR /tests
COPY package*.json ./
RUN npm ci
COPY . .
ENV CI=true
CMD ["npx", "playwright", "test"]
