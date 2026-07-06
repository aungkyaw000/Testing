#!/bin/bash

# အရောင်လေးတွေသတ်မှတ်ခြင်း
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Welcome Message
clear
echo -e "${CYAN}*************************************************${NC}"
echo -e "${CYAN}*                                               *${NC}"
echo -e "${GREEN}* Welcome to Aung Kyaw's Script (SSL Version)  *${NC}"
echo -e "${GREEN}* Created by Aung Kyaw                         *${NC}"
echo -e "${CYAN}*                                               *${NC}"
echo -e "${CYAN}*************************************************${NC}"
echo ""

# ၁။ Subdomain ကို အရင်မေးပါမယ်
read -p "Nginx SSL အတွက် အသုံးပြုမည့် Sub Domain (ဥပမာ - vpn.yourdomain.com): " DOMAIN_NAME
read -p "Certbot အတွက် Email ရိုက်ထည့်ပါ: " EMAIL

echo -e "\n${YELLOW}==========================================${NC}"
echo -e "${GREEN}၁။ Docker နှင့် လိုအပ်သည်များကို Install လုပ်နေပါသည်...${NC}"
echo -e "${YELLOW}==========================================${NC}"
sudo apt update && sudo apt install curl socat python3 python3-pip -y
curl -fsSL https://get.docker.com | sh

echo -e "\n${YELLOW}==========================================${NC}"
echo -e "${GREEN}၂။ Marzban ကို Install လုပ်နေပါသည်...${NC}"
echo -e "${YELLOW}==========================================${NC}"
# Marzban installation (non-interactive mode)
sudo bash -c "$(curl -sL https://github.com/Gozargah/Marzban-scripts/raw/master/marzban.sh)" @ install

echo -e "\n${YELLOW}==========================================${NC}"
echo -e "${GREEN}၃။ Marzban Admin အကောင့် ဖန်တီးပါ...${NC}"
echo -e "${YELLOW}==========================================${NC}"
marzban cli admin create --sudo

echo -e "\n${YELLOW}==========================================${NC}"
echo -e "${GREEN}၄။ Reality Key များကို ထုတ်ယူနေပါသည်...${NC}"
echo -e "${YELLOW}==========================================${NC}"
# Key ထုတ်ယူစဉ် Error မတက်အောင် ခဏစောင့်ပါ
sleep 5
KEYS=$(docker exec marzban-marzban-1 xray x25519)
PRIVATE_KEY=$(echo "$KEYS" | grep "Private key:" | awk '{print $3}' | tr -d '\r')
PUBLIC_KEY=$(echo "$KEYS" | grep "Public key:" | awk '{print $3}' | tr -d '\r')

# .env ထဲသို့ ထည့်သွင်းခြင်း
echo "" | sudo tee -a /opt/marzban/.env
echo "# Reality Keys" | sudo tee -a /opt/marzban/.env
echo "REALITY_PRIVATE_KEY=$PRIVATE_KEY" | sudo tee -a /opt/marzban/.env
echo "REALITY_PUBLIC_KEY=$PUBLIC_KEY" | sudo tee -a /opt/marzban/.env

echo -e "${CYAN}Public Key: $PUBLIC_KEY${NC}"

echo -e "\n${YELLOW}==========================================${NC}"
echo -e "${GREEN}၅။ Nginx နှင့် Certbot SSL ကို Install လုပ်နေပါသည်...${NC}"
echo -e "${YELLOW}==========================================${NC}"
sudo apt install nginx certbot python3-certbot-nginx -y

# Nginx config အခြေခံရေးသားခြင်း
sudo cat <<EOF > /etc/nginx/sites-available/marzban
server {
    listen 80;
    server_name $DOMAIN_NAME;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
EOF

sudo ln -sf /etc/nginx/sites-available/marzban /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo systemctl restart nginx

echo -e "\n${YELLOW}==========================================${NC}"
echo -e "${GREEN}၆။ SSL Certificate တောင်းခံနေပါသည် (Let's Encrypt)...${NC}"
echo -e "${YELLOW}==========================================${NC}"
# SSL တောင်းခြင်း (Auto Redirect ပါဝင်သည်)
sudo certbot --nginx -d $DOMAIN_NAME --non-interactive --agree-tos -m $EMAIL --redirect



echo -e "\n${CYAN}*************************************************${NC}"
echo -e "${GREEN}🎉 အားလုံးပြီးစီးပါပြီ!${NC}"
echo -e "${GREEN}Dashboard URL: ${YELLOW}https://$DOMAIN_NAME/dashboard${NC}"
echo -e "${GREEN}Laravel API URL: ${YELLOW}https://$DOMAIN_NAME${NC}"
echo -e "${CYAN}*************************************************${NC}\n"
