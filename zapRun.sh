#!/usr/bin/env bash

CONTAINER_ID=$(docker run -u zap -p 2375:2375 -d registry.intraway.com/owasp/zap2docker-stable zap.sh -daemon -port 2375 -host 127.0.0.1 -config api.disablekey=true -config scanner.attackOnStart=true -config view.mode=attack -config connection.dnsTtlSuccessfulQueries=-1 -config api.addrs.addr.name=.* -config api.addrs.addr.regex=true)

# the target URL for ZAP to scan
TARGET_URL=$1
TYPE_SCAN="quick"
REPORT_URL="report"
OUTPUT_FORMAT="html"

     docker exec $CONTAINER_ID zap-cli -p 2375 status -t 120 

    docker cp "/home/dmartinez/sso_web.context" $CONTAINER_ID:/zap
     docker cp "/home/dmartinez/sso.zst" $CONTAINER_ID:/zap


    docker  exec $CONTAINER_ID  zap-cli -p 2375 scripts load --name 'sso' --script-type 'proxy' -e 'Mozilla Zest' -f 'sso.zst'

    docker  exec $CONTAINER_ID  zap-cli -p 2375 scripts enable 'sso'

    docker exec $CONTAINER_ID zap-cli -p 2375 context import 'sso_web.context'
 
    docker exec $CONTAINER_ID zap-cli -p 2375 open-url $TARGET_URL

    docker exec $CONTAINER_ID zap-cli -p 2375 spider --context-name sso_web $TARGET_URL

    #  if [ $TYPE_SCAN == "quick" ]; then
    docker exec $CONTAINER_ID zap-cli -p 2375 active-scan  --recursive -c sso_web $TARGET_URL
    #  elif [ $TYPE_SCAN == "active" ]; then
    #      docker exec $CONTAINER_ID zap-cli -p 2375 spider $TARGET_URL
    #      docker exec $CONTAINER_ID zap-cli -p 2375 active-scan -r $TARGET_URL
    #  else
    #      echo "Error type scan"
    #  fi

      docker exec $CONTAINER_ID zap-cli -p 2375 alerts --output-format 'table'

      docker exec $CONTAINER_ID zap-cli -p 2375 report   --output-format $OUTPUT_FORMAT --output "report.$OUTPUT_FORMAT"

      docker cp $CONTAINER_ID:/zap/report.$OUTPUT_FORMAT $REPORT_URL.$OUTPUT_FORMAT

    #  divider==================================================================
    #  printf "\n"
    #  printf "$divider"
    #  printf "ZAP-daemon log output follows"
    #  printf "$divider"
    #  printf "\n"

   #  docker logs $CONTAINER_ID
     
     docker stop $CONTAINER_ID
