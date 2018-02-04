const express = require('express');
const {
  getAllDocsMatchingQuery,
  getAllDocsFromIds,
  insertOrUpdateSingleDoc,
  insertOrUpdateBulkDocs,
} = require('./src/myDb.js');

const app = express();

app.get('/', (req, res) => {
  if (req.query.bulk) {
    getAllDocsFromIds(req.query.bulk)
      .then(passedData => res.send(passedData));
  }
  if (req.query.keys().lenth === 1) {
    getAllDocsMatchingQuery(req.query)
      .then(passedData => res.send(passedData));
  }
  res.status(501).send();
});

app.post('/', (req, res) => {
  if (req.body.bulk) {
    insertOrUpdateBulkDocs(req.body)
      .then(confirmation => res.send(confirmation));
  }
  if (req.body.keys().length === 1) {
    insertOrUpdateSingleDoc(req.body)
      .then(confirmation => res.send(confirmation));
  }
  res.status(501).send();
});

app.listen('3000', () => console.log('Listening on port 3000...'));
