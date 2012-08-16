
/**
 * Module dependencies.
 */
require('coffee-script');

var express = require('express')
  , routes = require('./routes')
  , util = require('util')
  . async = require('async')
  , nforce = require('nforce');

var port = process.env.PORT || 3001; // use heroku's dynamic port or 3001 if localhost
var oauth;

var org = nforce.createConnection({
  clientId: process.env.CLIENT_ID,
  clientSecret: process.env.CLIENT_SECRET,
  redirectUri: 'http://localhost:' + port + '/oauth/_callback',
  apiVersion: 'v24.0',  // optional, defaults to v24.0
  environment: 'production'  // optional, sandbox or production, production default
});

console.log('authenticating....');
org.authenticate({ username: process.env.USERNAME, password: process.env.PASSWORD }, function(err, resp){
  if(err) {
    console.log('authenticate-> Error: ' + err.message);
  } else {
    console.log('Access Token: ' + resp.access_token);
    oauth = resp;
  }
});

var app = module.exports = express.createServer();

// Configuration

app.configure(function(){
  app.set('views', __dirname + '/views');
  app.set('view engine', 'jade');
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(app.router);
  app.use(express.static(__dirname + '/public'));
});

app.configure('development', function(){
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true }));
});

app.configure('production', function(){
  app.use(express.errorHandler());
});

// Routes

app.get('/', routes.index);

app.get('/accounts', function(req, res) {
	org.query('select id, name from account limit 10', oauth, function(err, resp){
    res.render("accounts", { title: 'Accounts', data: resp.records } );
	});
});

// form to create a new account
app.get('/accounts/new', function(req, res) {
  // call describe to dynamically generate the form fields
  org.getDescribe('Account', oauth, function(err, resp) {
    res.render('new', { title: 'New Account', data: resp })
  });
});

// create the account in salesforce
app.post('/accounts/create', function(req, res) {
  var obj = nforce.createSObject('Account', req.body.account);
  org.insert(obj, oauth, function(err, resp){
    if (err) {
      console.log(err);
    } else {
      if (resp.success == true) {
        res.redirect('/accounts/'+resp.id);
        res.end();
      }
    }
  })
});

// '###### PDF Generator changes ######'
// display the account in PDF format
app.get('/accounts/:id.pdf', function(req, res) {
  var async = require('async');
  var obj = nforce.createSObject('Account', {id: req.params.id});

  async.parallel([
      function(callback){
        org.query("select name, title, email, phone from contact where accountid = '" + req.params.id + "'", oauth, function(err, resp){
          callback(null, resp);
        });
      },
      function(callback){
        org.getRecord(obj, oauth, function(err, resp) {
          callback(null, resp);
        });
      },
      function(callback){
        org.query("select name from User where id in (select ownerID from account where id = '" + req.params.id + "')", oauth, function(err, resp){
          callback(null, resp);
        });
      },
  ],
  // optional callback
  function(err, results){
    // returns the responses in an array
    routes.accounts_details_pdf({ title: 'Account Details', data: results } , req, res);
  });  

});

// display the account
app.get('/accounts/:id', function(req, res) {
  var async = require('async');
  var obj = nforce.createSObject('Account', {id: req.params.id});

  async.parallel([
      function(callback){
        org.query("select count() from contact where accountid = '" + req.params.id + "'", oauth, function(err, resp){
          callback(null, resp);
        });
      },
      function(callback){
        org.getRecord(obj, oauth, function(err, resp) {
          callback(null, resp);
        });
      },
  ],
  // optional callback
  function(err, results){
    // returns the responses in an array
    res.render('show', { title: 'Account Details', data: results });
  });  

});

// form to update an existing account
app.get('/accounts/:id/edit', function(req, res) {
  var obj = nforce.createSObject('Account', {id: req.params.id});
  org.getRecord(obj, oauth, function(err, resp) {
    res.render('edit', { title: 'Edit Account', data: resp });
  });
});

// update teh account in salesforce
app.post('/accounts/:id/update', function(req, res) {
  var obj = nforce.createSObject('Account', req.body.account);
  org.update(obj, oauth, function(results) {
    res.redirect('/accounts/'+req.params.id);
    res.end();
  }); 
});

app.listen(port, function(){
  console.log("Express server listening on port %d in %s mode", app.address().port, app.settings.env);
});
