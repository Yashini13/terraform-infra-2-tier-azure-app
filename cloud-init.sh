#!/bin/bash
apt-get update -y
apt-get install -y nginx

cat > /var/www/html/index.html <<'EOF'
<!DOCTYPE html>
<html>
<head>
  <title>Backend API</title>
</head>
<body>
  <h1>VMSS Backend is running</h1>
  <p>Try /api/health through Application Gateway.</p>
</body>
</html>
EOF

mkdir -p /var/www/html/api

cat > /var/www/html/api/health <<'EOF'
{"status":"ok","backend":"vmss-instance"}
EOF

systemctl enable nginx
systemctl restart nginx