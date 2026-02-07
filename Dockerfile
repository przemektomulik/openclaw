FROM docker.io/cloudflare/sandbox:0.7.0

# Install dependencies for Google Chrome and WhatsApp
RUN apt-get update && apt-get install -y \
    xz-utils \
    ca-certificates \
    rsync \
    dumb-init \
    curl \
    gnupg \
    wget \
    --no-install-recommends

# Install Google Chrome (more reliable than chromium in Ubuntu Docker)
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update && apt-get install -y \
    google-chrome-stable \
    --no-install-recommends \
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
# Build cache bust: 2026-02-07-v4-aggressive-cleanup
COPY start-moltbot.sh /usr/local/bin/start-moltbot.sh
RUN chmod +x /usr/local/bin/start-moltbot.sh

COPY moltbot.json.template /root/.clawdbot-templates/moltbot.json.template
COPY skills/ /root/clawd/skills/

WORKDIR /root/clawd

# Use dumb-init to prevent zombie processes
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/usr/local/bin/start-moltbot.sh"]
