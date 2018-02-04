/* eslint no-underscore-dangle: "off" */
// CouchDB uses leading underscores in some key places that we need available to us.

const myDb = require('nano')('http://node_user:thisisreallysecure@localhost:5984/my_db');

function getAllDocsMatchingQuery(queryParams) {
  const qp = queryParams;
  return new Promise((resolve, reject) => {
    qp.include_docs = true;
    myDb.list(qp, (err, body) => {
      if (err) reject(new Error(`There was a problem querying the database.\n${err}`));
      resolve(body);
    });
  });
}

function getAllDocsFromIds(ids) {
  return new Promise((resolve, reject) => {
    myDb.fetch({ keys: ids }, (err, body) => {
      if (err) reject(new Error(`There was a problem querying the database.\n${err}`));
      resolve(body);
    });
  });
}

function insertOrUpdateSingleDoc(doc) {
  return new Promise((resolve, reject) => {
    const params = doc._id ? {} : doc.name.first;
    myDb.insert(doc, params, (err, body) => {
      if (err) reject(new Error(`There was a problem inserting data into the database.\n${err}`));
      resolve(body);
    });
  });
}

function insertOrUpdateBulkDocs(docs) {
  return new Promise((resolve, reject) => {
    myDb.bulk({ docs }, (err, body) => {
      if (err) reject(new Error(`There was a problem bulk inserting or updating into the database.\n${err}`));
      resolve(body);
    });
  });
}

module.exports = {
  myDb,
  getAllDocsMatchingQuery,
  getAllDocsFromIds,
  insertOrUpdateSingleDoc,
  insertOrUpdateBulkDocs,
};
