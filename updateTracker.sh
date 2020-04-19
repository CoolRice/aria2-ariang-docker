#!/bin/bash

HTTPS_URL="https://trackerslist.com/best_aria2.txt"
CURL_CMD="curl -w httpcode=%{http_code}"

ARIA2_CONF_PATH="/app/conf/aria2.conf"

# -m, --max-time <seconds> FOR curl operation
CURL_MAX_CONNECTION_TIMEOUT="-m 100"

# perform curl operation
CURL_RETURN_CODE=0
CURL_OUTPUT=`${CURL_CMD} ${CURL_MAX_CONNECTION_TIMEOUT} ${HTTPS_URL} 2> /dev/null` || CURL_RETURN_CODE=$?
if [ ${CURL_RETURN_CODE} -ne 0 ]; then
    echo "$(date) Curl connection failed with return code - ${CURL_RETURN_CODE}"
else
    # echo "Curl connection success"
    # Check http code for curl operation/response in  CURL_OUTPUT
    httpCode=$(echo "${CURL_OUTPUT}" | sed -e 's/.*\httpcode=//')
    if [ ${httpCode} -ne 200 ]; then
        echo "$(date) Curl operation/command failed due to server return code - ${httpCode}"
    else
        TRACKERS=$(echo "${CURL_OUTPUT}" | sed -e 's/\(.*\)httpcode=200/\1/')
        sedResult=$(sed -i "s|\(bt-tracker=\).*|\1${TRACKERS}|g" "${ARIA2_CONF_PATH}")
        if sed -i "s|\(bt-tracker=\).*|\1${TRACKERS}|g" "${ARIA2_CONF_PATH}"
        then
          echo "$(date) Update aria2 trackers done."
          kill 1
        else
          echo "$(date) Sed fail."
        fi
    fi
fi