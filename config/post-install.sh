#!/bin/bash
set -e

sudo apt update
sudo apt install -y build-essential python3-pip curl wget git htop net-tools wireguard wireguard-tools iptables
curl -fsSL https://ollama.com/install.sh | sh
sudo systemctl enable ollama
sudo systemctl start ollama
ollama pull mistral

sudo mkdir -p /opt/ai-server
sudo chown -R joachim:joachim /opt/ai-server
cd /opt/ai-server
python3 -m venv venv
source venv/bin/activate

cat > requirements.txt << "REQEOF"
fastapi==0.104.1
uvicorn[standard]==0.24.0
ollama==0.1.9
python-dotenv==1.0.0
pydantic==2.5.0
REQEOF
pip install -r requirements.txt

cat > main.py << "APPEOF"
from fastapi import FastAPI
import ollama

app = FastAPI(title="AI Server", version="1.0.0")

@app.get("/health")
async def health():
    return {"status": "healthy"}

@app.post("/api/v1/code-generate")
async def generate_code(prompt: str, model: str = "mistral"):
    response = ollama.generate(model=model, prompt=prompt, stream=False)
    return {"code": response["response"], "model": model}
APPEOF

sudo tee /etc/systemd/system/ai-server.service >/dev/null << "SVCEOF"
[Unit]
Description=AI Server FastAPI
After=network.target ollama.service
Wants=ollama.service

[Service]
Type=simple
User=joachim
WorkingDirectory=/opt/ai-server
Environment="PATH=/opt/ai-server/venv/bin"
ExecStart=/opt/ai-server/venv/bin/uvicorn main:app --host 0.0.0.0 --port 8000
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
SVCEOF

sudo systemctl daemon-reload
sudo systemctl enable ai-server
sudo systemctl start ai-server
