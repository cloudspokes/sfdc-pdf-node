PDFDocument = require 'pdfkit'
fs = require('fs');

class AccountDetails
  constructor: (@options = {}) ->
    @doc = new PDFDocument
   
    @doc.info['Title'] = 'SalesForce.com Report'
    @doc.info['Author'] = 'CloudSpokes Challenge - 1698'
    @last = 125

  ####### constructor - ENDS ########

 
  renderPage: (accountDetails, request, response) ->
    @drawHeader {}
    @drawAccountDetails accountDetails[1], accountDetails[2]
    @drawContactsTable  accountDetails[0]
    @drawFooter {}
    @doc.output (out) ->
      response.contentType("application/pdf")
      response.setHeader("Content-Length", out.length)
      response.end out, "binary"

   ####### renderPage - ENDS ########


  drawHeader: (options = {}) ->
    @doc.moveDown()
        .moveDown()
        .fontSize(18)
        .text('Account Details', 245, 80)
        .image('images/salesForce.png', 45, 20, width: 120,height: 120)
        .image('images/company_logo.png', 500, 30, width: 80,height: 80 )
        
    @doc.fontSize(12)

  ####### drawHeader - ENDS ########


  drawAccountDetails: (accountDetails, owner) ->
    
    #drawAccountDetailsLine: (left_title, left_data, right_title, right_data, line_number)
    @drawAccountDetailsLine 'Account Owner:', owner.records[0].Name, 'Rating:', accountDetails.Rating, @last
    @last = @last + 20
    @drawAccountDetailsLine 'Account Name:', accountDetails.Name, 'Phone:', accountDetails.Phone, @last
    @last = @last + 20
    @drawAccountDetailsLine 'Account Number:', accountDetails.AccountNumber, 'Fax:',  accountDetails.Fax, @last
    @last = @last + 20
    @drawAccountDetailsLine 'WebSite:',  { isLink: "true", text: @fixHTTPURLs(accountDetails.Website) }, 'Site:', accountDetails.Site,  @last
    @last = @last + 20
    @drawAccountDetailsLine 'Type:',  accountDetails.Type, 'Ticker:', accountDetails.TickerSymbol,  @last
    @last = @last + 20
    formattedNumber = if accountDetails.AnnualRevenue? then '$' + @formatNumber accountDetails.AnnualRevenue else 'N/A'
    formatedEmployees = @formatNumber accountDetails.NumberOfEmployees
    @drawAccountDetailsLine 'Annual Revenue:', formattedNumber, 'Employees:', formatedEmployees,  @last
    @last = @last + 20
    @drawAccountDetailsLine 'Billing:',  accountDetails.BillingStreet, 'Shipping:', accountDetails.ShippingStreet,  @last
    w = @doc.widthOfString(accountDetails.ShippingStreet)
    if w > 300
      @last = @last + 100
    else 
      @last = @last + 50 

  ####### drawAccountDetails - ENDS ########


  drawAccountDetailsLine: (left_title, left_data, right_title, right_data, line_number) ->

    @doc.fillAndStroke("gray", "gray")
    @doc.text  left_title, 55, line_number, 
      width: 100
      align: 'left'
    @doc.fillAndStroke("black", "black")
    if typeof left_data.isLink == "undefined" 
      left_text = if left_data? then left_data else 'N/A'
      @doc.text left_text, 165, line_number, 
        width: 200
        align: 'left'
    else
      @drawALink left_data.text, 165, line_number
   
    @doc.fillAndStroke("gray", "gray")
    @doc.text  right_title, 380, line_number, 
      width: 100
      align: 'left'
    @doc.fillAndStroke("black", "black")
    right_text = if right_data? then right_data else 'N/A'
    @doc.text  right_text, 450, line_number, 
              width: 100
              align: 'left'
    

  ####### drawAccountDetailsLine - ENDS ########

  drawALink: (linkText, col, row) ->
    # Add the link text
    @doc.fontSize(12)
      .fillColor('blue')
      .text(linkText, col, row)

    # Measure the text
    width = @doc.widthOfString(linkText)
    height = @doc.currentLineHeight()   

    # Add the underline and link annotations
    @doc.underline(col, row, width, height, color: 'blue')
      .link(col, row, width, height, linkText)


  drawContactsTable: (contacts) ->
    @drawContactsTableHeader {}
    @drawContactsTableData contacts
    @drawContactsTableEndOfReport {"recordCount" : contacts.records.length}

  ####### drawContactsTable - ENDS ########

  formatNumber: (numberStr) ->
    if numberStr?
      numberStr += ''
      x = numberStr.split('.');
      x1 = x[0];
      x2 = ''
      if x.length > 1 
        x2 = '.' + x[1]
      rgx = /(\d+)(\d{3})/;
      while (rgx.test(x1)) 
        x1 = x1.replace(rgx, '$1' + ',' + '$2')
      formatedNumber = x1 + x2
      formatedNumber
    else 
       ""

  fixHTTPURLs: (httpURL) ->
    x = httpURL.split('http');
    if x.length > 1
      httpURL
    else 
      'http://' + httpURL

  ####### formatNumber - ENDS ########

  drawContactsTableHeader: (options = {}) ->

    @last = @last + 20
    # Contacts Table Title
    @doc.fontSize(16)
    @doc.text  'Contacts', 275, @last, 
      width: 910
      align: 'left'
      height: 5
    @doc.fillAndStroke("black", "black")
    @doc.fontSize(12)

    @last = @last + 20
    # Header start Line
    @doc.lineWidth(5)
    @doc.lineCap('butt')
      .moveTo(45, @last)
      .lineTo(575, @last)
      .stroke()

    @last = @last + 10
    # Header Background
    @doc.lineWidth(20)
    @doc.lineCap('butt')
      .moveTo(45, @last)
      .lineTo(575, @last)
      .fillOpacity(0.8)
      .fillAndStroke("black", "#d1f4f4")
      .stroke()

    @last = @last - 5
    # Header Titles
    @doc.text  'Contact Name', 55, @last, 
      width: 410
      align: 'left'

    @doc.text  'Title', 170, @last, 
      width: 410
      align: 'left'

    @doc.text  'Email', 340, @last, 
      width: 410
      align: 'left'

    @doc.text  'Phone', 460, @last, 
      width: 410
      align: 'left'

    @last = @last + 15
    # Header End line
    @doc.lineWidth(1)
    @doc.lineCap('butt')
      .moveTo(45, @last)
      .lineTo(575, @last)
      .fillAndStroke("gray", "gray")
      .stroke()

  ####### drawContactsTableHeader - ENDS ########



  drawContactsTableData: (contacts) ->
    rowCount = 0
    for contact in contacts.records
      if (rowCount % 2) == 0
        @doc.lineCap('butt')
          .fillAndStroke("black", "#ffebf5")
      else
        @doc.lineCap('butt')
          .fillAndStroke("#504c4f", "#ededed")
      
      @last = @last + 10
      # Data 1
      @doc.text  contact.Name, 55, @last, 
        width: 300
        align: 'left'

      @doc.text  contact.Title , 170, @last, 
        width: 300
        align: 'left'

      @doc.text  contact.Email, 340, @last, 
        width: 300
        align: 'left'

      @doc.text  contact.Phone, 460, @last, 
        width: 300
        align: 'left'

      @last = @last + 10

      rowCount = rowCount + 1
      
  ####### drawContactsTableData - ENDS ########


  drawContactsTableEndOfReport: (options = {}) ->

    @last = @last + 10
    # Header start Line
    @doc.lineWidth(2)
    @doc.lineCap('butt')
     .moveTo(45, @last)
     .lineTo(575, @last)
     .fillAndStroke("black", "black")
     .stroke()
    
    @last = @last + 10
    @doc.text  'Number of Contacts: ' + options.recordCount, 440, @last, 
      width: 350
      align: 'left'

    @last = @last + 20
    @doc.lineWidth(2)
    @doc.lineCap('butt')
     .moveTo(45, @last)
     .lineTo(575, @last)
     .fillAndStroke("black", "black")
     .stroke()

  ####### drawContactsTableEndOfReport - ENDS ########

  drawFooter: (options = {}) ->
    @last = @last + 10
    @doc.text  'Copyright © 2000-2012 salesforce.com, inc. All rights reserved.', 150, @last, 
      width: 350
      align: 'left'
    
  ####### drawFooter - ENDS ########


module.exports = AccountDetails


