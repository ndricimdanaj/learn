#!/bin/bash
IPT="/usr/bin/sudo /sbin/iptables"

IP=$2
CN=$3

CHAIN=in_$2

echo "$1;$2;$3"

echo "Running connect script"

case "$1" in
add|update)
echo "Adding rules for IP: $IP/$CN"
if ! command -v jq &> /dev/null
then
    echo "'jq' could not be found!"
    echo "Install with 'apt install jq'"
    exit 1;
fi

echo "Getting service token"
SSO_URL="https://sso.swarco.com"  # https://sso.swarco.com https://dev.cip.swarco.com
MYCITY_URL="https://mycity.swarco.com"


#SSO_URL="https://staging.cip.auth.loc" # https://staging.cip.swarco.com  # https://sso.swarco.com
#MYCITY_URL="https://staging.cip.auth.loc"

# Notes:
# client_id and client_credentials are DIFFERENT for each envinromment (dev + testing + staging + prod)
# The URL to fetch token is NOT necessarily the same as for the api call. on dev + testing + staging keycloak has the same DNS entry. On prod its sso.swarco.com
response=$(curl -s -X POST -H "Content-Type: application/x-www-form-urlencoded" -d 'grant_type=client_credentials&client_id=swarco.vpn.connect.client&client_secret=secretVpnConnectClientKCsecret' "$SSO_URL/auth/realms/swarco/protocol/openid-connect/token")

token=$(echo $response | jq -r '.access_token')
if [ "$token" == "" ]; then
  echo "Kein Token"
  # exit 1 will probihit openvpn to include this user into its routing table. SHOULD STAY 1
  logger -p local7.error "Unable to get token for $CN"
  exit 1;
fi

logger -p local7.info "Getting subnets for $CN"
HTTP_RESPONSE=$(curl -m 60 -s -w "HTTPSTATUS:%{http_code}" -H "authorization: Bearer $token" "$MYCITY_URL/api/swarco.core.ip-pool-manager/impersonate/$CN/subnets")
echo "$HTTP_RESPONSE"
HTTP_STATUS=$(echo $HTTP_RESPONSE | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
HTTP_BODY=$(echo $HTTP_RESPONSE | sed -e 's/HTTPSTATUS\:.*//g')

echo "status: $HTTP_STATUS"
echo "body: $HTTP_BODY"

if [ ! $HTTP_STATUS -eq 200  ]; then
  logger -p local7.error "subnets request failed with status: $HTTP_STATUS, response: $HTTP_BODY"
  # exit 1 will probihit openvpn to include this user into its routing table. SHOULD STAY 1
  exit 1;
fi
echo $HTTP_BODY

HOST=$HTTP_BODY

#Parsing response to a bash array
HOST=$(echo $HOST | tr -d '[]"')
HOST=(${HOST//,/$' '})

if [ "$HOST" = "" ]; then
  echo "empty response"
  logger -p local7.error "NO rules for $CN"
  # exit 1 will probihit openvpn to include this user into its routing table. SHOULD STAY 1
  exit 1;
fi

logger -p local7.info "Add rules for $IP / $CN"

# if the chain exists, flush it, otherwise create it
$IPT -n --list $CHAIN >/dev/null 2>&1
if [ "$?" == "0" ]; then
  $IPT -F $CHAIN
  # The link rule might also exist already, check it
  $IPT -C FORWARD -j $CHAIN >/dev/null 2>&1
  # This  is 0 if the rule exists and 1 if not
  ADDRULE=$?
else
  $IPT -N $CHAIN
  ADDRULE=1
fi

for host in "${HOST[@]}"; do
  #$IPT -I $CHAIN -d $host -j ACCEPT
  # Accept traffic from user on tun0 to device on ens192
  $IPT -I $CHAIN -i tun0 -o ens192 -s $IP -d $host -j ACCEPT
  # Accept traffic from device on ens192 to user on tun0
  $IPT -I $CHAIN -i ens192 -o tun0 -s $host -d $IP -j ACCEPT
done;

# Route all traffic coming from the VPN to the  chain
# We just block connections from user to the devices
if [ "$ADDRULE" != 0 ]; then
  $IPT -I FORWARD -j $CHAIN
fi;

;;
delete)
  logger -p local7.info "Clear rules for $IP"
  echo "Clear rules for $IP"
  $IPT -D FORWARD -j $CHAIN
  $IPT -F $CHAIN
  $IPT -X $CHAIN
;;
esac

#everything worked as expected exit with 0
exit 0;
