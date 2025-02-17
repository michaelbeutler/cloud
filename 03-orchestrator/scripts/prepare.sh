# Install oh my bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"

# Set default theme to cloud
sed -i 's/OSH_THEME=.*/OSH_THEME="cloud"/' ~/.bashrc

# Disable swap
swapoff -a
sed -i.bak '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
systemctl mask swap.target

# Disable firewall
ufw disable