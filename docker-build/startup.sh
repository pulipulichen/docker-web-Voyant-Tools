#!/bin/bash

# ----------------------------------------------------------------

waitForConntaction() {
  port="$1"
  sleep 3
  while true; do
    echo "http://127.0.0.1:$port"
    if curl -sSf "http://127.0.0.1:$port" >/dev/null 2>&1; then
      echo "Connection successful."
      break
    else
      #echo "Connection failed. Retrying in 5 seconds..."
      sleep 5
    fi
  done
}

# ----------------------------------------------------------------

rm -f "${LOCAL_VOLUMN_PATH}/.docker-web.ready" || true
rm -f "${LOCAL_VOLUMN_PATH}/.cloudflare.url" || true
ls -la "${LOCAL_VOLUMN_PATH}/"

INITED="true"

# if [ ! -e "${LOCAL_VOLUMN_PATH}/solrconfig.xml" ]; then
#   ln -s "${LOCAL_VOLUMN_PATH}"solrconfig.xml.txt "${LOCAL_VOLUMN_PATH}"solrconfig.xml
# fi

#docker-entrypoint.sh solr-foreground -force -Dsolr.clustering.enabled=true &
# solr start -force -f -Dsolr.clustering.enabled=true &

#echo "BEFORE ================================================================="
waitForConntaction "${LOCAL_PORT}"
#echo "AFTER ================================================================="

sleep 10

if [ "$INITED" != "true" ]; then
  sleep 30
fi

# ----------------------------------------------------------------

setupCloudflare() {
  file="/tmp/cloudflared"
  if [ ! -f "$file" ]; then
    wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O "${file}"
    chmod a+x "${file}"
  fi
}

runCloudflare() {
  port="$1"
  file_path="$2"

  #echo "p ${port} ${file_path}"

  rm -rf "${file_path}"
  #nohup /tmp/.cloudflared --url "http://127.0.0.1:${port}" > "${file_path}" 2>&1 &
  /tmp/cloudflared --url "http://127.0.0.1:${port}" > "${file_path}" 2>&1 &
}

getCloudflarePublicURL() {
  setupCloudflare

  port="$1"

    # File path
  file_path="/tmp/cloudflared.out"

  runCloudflare "${port}" "${file_path}" &

  sleep 3

  # Extracting the URL using grep and awk
  url=$(grep -o 'https://[^ ]*\.trycloudflare\.com' "$file_path" | awk '/https:\/\/[^ ]*\.trycloudflare\.com/{print; exit}')

  echo "$url/solr/collection/browse"
}

getCloudflarePublicURL "${LOCAL_PORT}" > "${LOCAL_VOLUMN_PATH}/.cloudflare.url"

# ----------------------------------------------------------------


url="http://127.0.0.1:${LOCAL_PORT}/solr/collection/browse"

while true; do
    response=$(curl -s "$url")
    #echo "$response"
    if [[ $(echo "$response" | jq -e . 2>/dev/null) ]]; then
        echo "Received JSON, sleeping for 5 seconds..."
        sleep 5
    elif [[ $response == *"<html>"* ]]; then
        sleep 10
        echo "Received HTML, it's okay!"
        break
    else
        echo "Unexpected response. Exiting."
        #exit 1
        sleep 5
    fi
done

echo `date` > "${LOCAL_VOLUMN_PATH}/.docker-web.ready"

echo "================================================================"
echo "Voyant Tools are ready to serve."
echo "================================================================"

# ----------------------------------------------------------------

while true; do
  sleep 10
done