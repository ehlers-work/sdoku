#!/bin/bash
while true; do
  docker ps && break
  echo "waiting for docker to respond"
  sleep 3
done

echo "Generating nip.io based on found external IP"
FOUNDIP=$(docker run --rm --net=host appropriate/curl https://api.ipify.org)
FQDN="git.${FOUNDIP}.nip.io"

# Generate certificates
curl https://gist.githubusercontent.com/superseb/b2c1d6c9baa32609a49ee117a27bc700/raw/7cb196e974e13b213ac6ec3105971dd5e21e4c66/selfsignedcert.sh | bash -s -- $FQDN

# nginx
cat <<EOF > $PWD/nginx.conf
server {
    listen 80;
    server_name $FQDN;
    return 301 https://$FQDN$request_uri;
}
server {
    listen               443 ssl;
    server_name          $FQDN;
    
    # To allow special characters in headers
    ignore_invalid_headers off;
    # Allow any size file to be uploaded.
    # Set to a value such as 1000m; to restrict file size to a specific value
    client_max_body_size 0;
    # To disable buffering
    proxy_buffering off;
     
    ssl_certificate      /certs/cert.pem;
    ssl_certificate_key  /certs/key.pem;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;

    location / {
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header Host \$http_host;
        
        proxy_connect_timeout 300;
        # Default is HTTP/1, keepalive is only enabled in HTTP/1.1
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        chunked_transfer_encoding off;
        proxy_pass       https://github.com:443;
    }
}

EOF

docker run -d --name=nginx -p 80:80 -p 443:443 -v $PWD/nginx.conf:/etc/nginx/conf.d/git.conf:ro -v $PWD/certs:/certs nginx

INFOFILE=./git-info.txt
echo "CA PEM certificate" | tee -a ./git-info.txt
echo "---" | tee -a ./git-info.txt
cat $PWD/certs/ca.pem | tee -a ./git-info.txt
echo "---" | tee -a ./git-info.txt
echo "CA PEM certificate (base64)" | tee -a ./git-info.txt
echo "---" | tee -a ./git-info.txt
cat $PWD/certs/ca.pem | base64 -w0 | tee -a ./git-info.txt
echo "---" | tee -a ./git-info.txt
echo "CA DER certificate (base64)" | tee -a ./git-info.txt
echo "---" | tee -a ./git-info.txt
openssl x509 -outform der -in $PWD/certs/ca.pem | base64 -w0 | tee -a ./git-info.txt
echo "---" | tee -a ./git-info.txt
echo "" | tee -a ./git-info.txt
echo "URL: https://${FQDN}" | tee -a ./git-info.txt
echo "Test URL: https://${FQDN}/octocat/Hello-World" | tee -a ./git-info.txt
echo "" | tee -a ./git-info.txt
echo "Testcommand:" | tee -a ./git-info.txt 
echo "git -c http.sslCAInfo=${PWD}/certs/ca.pem clone https://${FQDN}/octocat/Hello-World" | tee -a ./git-info.txt
echo "All of this info is also stored in ${INFOFILE}"