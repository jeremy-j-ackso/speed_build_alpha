# Need to install
# couchdb
# Node8
# NGINX

apt-get update
apt-get upgrade

curl -sL https://deb.nodesource.com/setup_8.x | bash -

apt-get install -y couchdb nginx nodejs

# Copy over the nginx configs.
cp /etc/nginx/nginx.conf /etc/nginx/bak_nginx.conf
cp /Vagrant/vagrant-scripts/nginx.conf /etc/nginx/nginx.conf

# Create my_db if none exists.
curl -X PUT http://localhost:5984/my_db

# Create a _users database for couchdb if none exists.
curl -X PUT http://localhost:5984/_users

# Insert an admin user into the database
curl -X PUT http://localhost:5984/_config/admins/administrator --data '"squirrel"'

# Insert a node_user to couchdb so that we can control query.
# node_user should have rw permissions to my_db
curl -X PUT http://administrator:squirrel@localhost:5984/_users --data '{"_id": "org.couchdb.user:node_user", "name": "node_user", "password": "secret", "roles": ["api"], "type": "user"}'

# Set the _security document of `my_db` so only users with role "api" can read/write regular documents.
curl -X PUT http://administrator:squirrel@localhost:5984/my_db/_security --data '{"admin": {"names": [], "roles": []}, "members": {"names": ["node_user"], "roles": ["api"]}}'
