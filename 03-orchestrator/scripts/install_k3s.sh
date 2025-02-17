# if K3S_URL and K3S_TOKEN are not set, install k3s server
if [ -z "$K3S_URL" ] && [ -z "$K3S_TOKEN" ]; then
  curl -sfL https://get.k3s.io | sh -
else
  curl -sfL https://get.k3s.io | K3S_URL=$K3S_URL K3S_TOKEN=$K3S_TOKEN sh -
fi