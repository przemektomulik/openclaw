FROM docker.io/cloudflare/sandbox:0.7.0

# Install Chromium and dependencies for WhatsApp channel
RUN apt-get update && apt-get install -y \
    xz-utils \
    ca-certificates \
    rsync \
    dumb-init \
    chromium \
    libnss3 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxrandr2 \
    libgbm1 \
    libasound2 \
    libpangocairo-1.0-0 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 22
ENV NODE_VERSION=22.13.1
RUN curl -fsSLk https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz -o /tmp/node.tar.xz \
    && tar -xJf /tmp/node.tar.xz -C /usr/local --strip-components=1 \
    && rm /tmp/node.tar.xz

# Install moltbot
RUN npm install -g clawdbot@2026.1.24-3

# Setup directories
RUN mkdir -p /root/.clawdbot /root/.clawdbot-templates /root/clawd/skills

# Copy startup script
# Build cache bust: 2026-02-07-v2-chromium
COPY start-moltbot.sh /usr/local/bin/start-moltbot.sh
RUN chmod +x /usr/local/bin/start-moltbot.sh

COPY moltbot.json.template /root/.clawdbot-templates/moltbot.json.template
COPY skills/ /root/clawd/skills/

WORKDIR /root/clawd

# Use dumb-init to prevent zombie processes (the 180 process issue)
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/usr/local/bin/start-moltbot.sh"]
