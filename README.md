# Config repository for any VPN Server in MyCity

Each VPN Solution (Legacy, Prod, Staging) has a general.config file where the OS changes are kept.

Besides that, follow the changes in every folder within the VPN Solution.

# check out the documentation

https://confluence.swarco.com/display/CIP/VPN+Settings+on+VPN+servers
https://confluence.swarco.com/display/CIP/Add+a+Device

# Generate CSR for VPN Server

openssl req -newkey rsa:2048 -nodes -keyout PRIVATEKEY.key -out MYCSR.csr

openssl req -newkey rsa:2048 -nodes -keyout staging.cip.swarco.com.key -out staging.cip.swarco.com.csr

openssl req -newkey rsa:2048 -nodes -keyout vpn07-legacy.key -out vpn07-legacy.csr

openssl req -newkey rsa:2048 -nodes -keyout vpn-02-topic-test-with-netscape.key -out vpn-02-topic-test-with-netscape.csr

openssl req -newkey rsa:2048 -nodes -keyout vpn07-legacy-test-with-netscape.key -out vpn07-legacy-test-with-netscape.csr
openssl req -newkey rsa:2048 -nodes -keyout vpn07-legacy-test-no-netscape.key -out vpn07-legacy-test-no-netscape.csr

openssl req -newkey rsa:2048 -nodes -keyout vpn06-legacy-prod-with-netscape.key -out vpn06-legacy-prod-with-netscape.csr

openssl req -newkey rsa:2048 -nodes -keyout vpn07-legacy-prod-with-netscape.key -out vpn07-legacy-prod-with-netscape.csr


# create user for VPN instance

sudo adduser --home /nonexistent --no-create-home --disabled-login --shell /usr/sbin/nologin  USERNAMEHERE
sudo adduser --home /nonexistent --no-create-home --disabled-login --shell /usr/sbin/nologin  vpn07-legacy
sudo adduser --home /nonexistent --no-create-home --disabled-login --shell /usr/sbin/nologin  vpn06-legacy

sudo adduser --home /nonexistent --no-create-home --disabled-login --shell /usr/sbin/nologin  vpn-02-topic


sudo adduser --home /nonexistent --no-create-home --disabled-login --shell /usr/sbin/nologin  vpn07-legacy
sudo adduser --home /nonexistent --no-create-home --disabled-login --shell /usr/sbin/nologin  vpn-03-topic

# create diffiehellman kex params

sudo openssl dhparam -out dh2048.pem 2048
sudo chmod 600 dh2048.pem



## installation  of additional libs
### OpenSSL
https://medium.com/@brunoosiek/updating-openssl-latest-and-greatest-version-in-ubuntu-18-04-8f10ba4e2377

sudo tar xfzv openssl-[version].tar.gz --directory /opt/openssl
sudo mkdir /opt/openssl/[version]
cd /opt/openssl/openssl-[version]
sudo ./config --prefix=/opt/openssl/[version] --openssldir=/opt/openssl/[version]/ssl

#### to change the Openssl version just change the symlink

rm /usr/bin/openssl
sudo ln -s /opt/openssl/[target-version]/bin/openssl /usr/bin/openssl

#### Example

sudo tar xfzv openssl-1.0.0e.tar.gz --directory /opt/openssl
sudo mkdir /opt/openssl/1.0.0e
cd /opt/openssl/openssl-1.0.0e
sudo ./config --prefix=/opt/openssl/1.0.0e --openssldir=/opt/openssl/1.0.0e/ssl

sudo make
sudo make install

sudo ln -s /opt/openssl/1.0.0e/bin/openssl /usr/bin/openssl
ls -lisah /usr/bin/openssl


sudo ln -s /opt/openssl/0.9.7i/bin/openssl /usr/bin/openssl

### OpenVPN

sudo tar xfzv openvpn-[version].tar.gz --directory /opt/openvpn
cd /opt/openvpn-[version]/

./configure
sudo make
sudo make install

sudo ln -s /opt/openvpn/openvpn-[version]/openvpn /usr/bin/openvpn

#### Example

sudo tar xfzv openvpn-2.1.3.tar.gz --directory /opt/openvpn

cd /opt/openvpn-2.1.3/

./configure
sudo make
sudo make install

sudo ln -s /opt/openvpn/openvpn-2.1.3/openvpn /usr/bin/openvpn


# Setup  Test VM with old security packages
 
There is a VM with 
    Openssl 0.9.7i,1.0.0e 
    Openvpn 2.0.7, 2.0.9, 2.1.3
to test the connection to the legacy VPN Servers.



Ask Maik Illner to get access to that machine.
