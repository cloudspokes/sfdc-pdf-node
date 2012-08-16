
This app is the node app for challenge 1698 from CloudSpokes.
This application generates 'Pretty' PDF report for the Account Details.

Prerequisites
------------------
Make sure you have node and npm installed.


Setup
------------------
Run 'npm install' the first time.


Running
------------------
Run 'node app.js'.



Changes from Original Version:
=============================

The following files were changed:

   - apps.js
     Added a URL mapping to receive 'GET' requests for PDF extensions.
     These requests will be routed to a module that will generate the PDF based on the data requested in salesforce.com
     See the line starting with '###### PDF Generator changes ######'

   - accounts.jade
     Added PDF extension to URLs to make test easier.
    
   - index.js
     Added a route that forwards PDF requests and generates the PDF with the provided data.

   - accountDetails.coffee (added)
     This is the bulk of the work.
     This module contains a public method 'renderPage', which generates the PDF with the provided data
     and and sends it back to the Browser thru the response object.
     
      Here is a sample of the flow performed in this method:
	    - drawHeader :
	       In here the logos and main Header title are displayed.
	
	    - drawAccountDetails 
	       This displays the details of the Account being queried.
	
	    - drawContactsTable
	       This displays the contact tables.
	
	    - drawFooter 
	       This displays the copy right, etc...
	
	    - At the generated PDF is sent back to the browser: @doc.output... 
	
	  I had to fix some data here and there and make some text display adjustments, see the following helper methods:
	     - drawALink
	     - formatNumber
	     - fixHTTPURLs
	 

   - images (folder added)
     Added some images to be used in the PDF file generated.


Demo
========================

http://quiet-reaches-5178.herokuapp.com/accounts

