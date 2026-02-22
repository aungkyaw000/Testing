#!/bin/bash

# အရောင်လေးတွေသတ်မှတ်ခြင်း
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Welcome Message
clear
echo -e "${CYAN}*************************************************${NC}"
echo -e "${CYAN}* *${NC}"
echo -e "${GREEN}* Welcome to Aung Kyaw's Script         *${NC}"
echo -e "${GREEN}* Created by Aung Kyaw              *${NC}"
echo -e "${CYAN}* *${NC}"
echo -e "${CYAN}*************************************************${NC}"
echo ""

# ၁။ Subdomain ကို အရင်မေးပါမယ်
read -p "Nginx အတွက် အသုံးပြုမည့် Sub Domain (ဥပမာ - vpn.yourdomain.com) ကို ရိုက်ထည့်ပါ: " DOMAIN_NAME

echo -e "\n${YELLOW}==========================================${NC}"
echo -e "${GREEN}၁။ Docker ကို Install လုပ်နေပါသည်...${NC}"
echo -e "${YELLOW}==========================================${NC}"
curl -fsSL https://get.docker.com | sh

echo -e "\n${YELLOW}==========================================${NC}"
echo -e "${GREEN}၂။ Marzban ကို Install လုပ်နေပါသည်...${NC}"
echo -e "${YELLOW}==========================================${NC}"
sudo bash -c "$(curl -sL https://github.com/Gozargah/Marzban-scripts/raw/master/marzban.sh)" @ install

echo -e "\n${YELLOW}==========================================${NC}"
echo -e "${GREEN}၃။ Marzban Admin အကောင့် ဖန်တီးပါ (username နှင့် password ရိုက်ထည့်ပါ)...${NC}"
echo -e "${YELLOW}==========================================${NC}"
marzban cli admin create --sudo

echo -e "\n${YELLOW}==========================================${NC}"
echo -e "${GREEN}၄။ Public & Private Key (Reality အတွက်) ထုတ်ပေးနေပါသည်...${NC}"
echo -e "${YELLOW}==========================================${NC}"
# Marzban container အတွင်းရှိ xray ဖြင့် key ထုတ်ခြင်း
docker exec -it marzban xray x25519
echo -e "${CYAN}(အထက်ပါ Private Key နှင့် Public Key ကို သေချာမှတ်ထားပါ/Copy ကူးထားပါ)${NC}"

echo -e "\n${YELLOW}==========================================${NC}"
echo -e "${GREEN}၅။ Nginx ကို Install လုပ်နေပါသည်...${NC}"
echo -e "${YELLOW}==========================================${NC}"
sudo apt update && sudo apt install nginx -y

echo -e "\n${YELLOW}==========================================${NC}"
echo -e "${GREEN}၆။ Nginx Configuration ကို ထည့်သွင်းနေပါသည်...${NC}"
echo -e "${YELLOW}==========================================${NC}"
# အဟောင်းရှိရင် ဖျက်ပါမယ်
sudo rm -f /etc/nginx/sites-available/marzban
sudo rm -f /etc/nginx/sites-enabled/marzban

# Config အသစ်ရေးထည့်ခြင်း (cat EOF ဖြင့်)
sudo cat <<EOF > /etc/nginx/sites-available/marzban
server {
    listen 80;
    server_name $DOMAIN_NAME;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF

# Symlink ပြန်ချိတ်ခြင်း
sudo ln -s /etc/nginx/sites-available/marzban /etc/nginx/sites-enabled/

echo -e "\n${YELLOW}==========================================${NC}"
echo -e "${GREEN}၇။ Nginx ကို Test လုပ်ပြီး Restart ချနေပါသည်...${NC}"
echo -e "${YELLOW}==========================================${NC}"
sudo nginx -t
sudo systemctl restart nginx

echo -e "\n${CYAN}*************************************************${NC}"
echo -e "${GREEN}🎉 အားလုံးပြီးစီးပါပြီ! Aung Kyaw ရဲ့ Marzban ကို ${YELLOW}$DOMAIN_NAME${GREEN} ဖြင့် ဝင်ရောက်အသုံးပြုနိုင်ပါပြီ။${NC}"
echo -e "${CYAN}*************************************************${NC}\n"
