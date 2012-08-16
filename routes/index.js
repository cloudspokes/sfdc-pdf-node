var accountDetails = require('./accountDetails');
/*
 * GET home page.
 */

exports.index = function(req, res){
  res.render('index', { title: 'Welcome to the Salesforce CRUD demo with Node.js' })
};

exports.accounts_details_pdf = function(accountDetailsData, request, response) {
	 var accountDetailsPDF = new accountDetails
	 accountDetailsPDF.renderPage(accountDetailsData.data, request, response);
};