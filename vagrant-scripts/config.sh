# Need to install
# couchdb
# Node8
# NGINX

# Add the CouchDB repo's.
echo "deb https://apache.bintray.com/couchdb-deb xenial main" > /etc/apt/sources.list.d/couch.list
curl -sL https://couchdb.apache.org/repo/bintray-pubkey.asc | apt-key add -

# Installs Node 8 repos
curl -sL https://deb.nodesource.com/setup_8.x | bash - # This runs apt-get update for me.

# Install all the dependencies
apt-get upgrade -q -y
apt-get install -q -y nginx nodejs

# Need to prep some responses for installing couchdb from this source.
COUCHDB_PASSWORD="squirrel"
echo "couchdb couchdb/mode select standalone
couchdb couchdb/mode seen true
couchdb couchdb/bindaddress string 127.0.0.1
couchdb couchdb/bindaddress seen true
couchdb couchdb/adminpass password ${COUCHDB_PASSWORD}
couchdb couchdb/adminpass seen true
couchdb couchdb/adminpass_again password ${COUCHDB_PASSWORD}
couchdb couchdb/adminpass_again seen true" | debconf-set-selections
DEBIAN_FRONTEND=noninteractive apt-get install -y couchdb

# Copy over the nginx configs.
mv /etc/nginx/sites-available/default /etc/nginx/sites-available/.default
cp /vagrant/vagrant-scripts/api_conf /etc/nginx/sites-available/api_conf
ln --symbolic /etc/nginx/sites-available/api_conf /etc/nginx/sites-enabled/api_conf

# Create my_db if none exists.
curl -s -X PUT http://admin:squirrel@localhost:5984/my_db

# Insert a node_user to couchdb so that we can control query.
# node_user should have rw permissions to my_db
curl -s -X POST http://admin:squirrel@localhost:5984/_users \
  --data '{"_id": "org.couchdb.user:node_user", "name": "node_user", "password": "thisisreallysecure", "roles": ["api"], "type": "user"}' \
  -H "Accept: application/json" \
  -H "Content-Type: application/json"
  

# Set the _security document of `my_db` so only users with role "api" can read/write regular documents.
curl -s -X PUT http://admin:squirrel@localhost:5984/my_db/_security \
  --data '{"admin": {"names": [], "roles": []}, "members": {"names": ["node_user"], "roles": ["api"]}}'

shutdown -r now
