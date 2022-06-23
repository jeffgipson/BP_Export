  require 'csv'
  require 'json'
  require "uri"
  require "net/http"
  require 'open-uri'
  require 'cgi'

  pagenumber = 49

  # while pagenumber < 82
  #   puts pagenumber

  url = URI("https://api.betterproposals.io/proposal?page=1&per_page=20000")

  https = Net::HTTP.new(url.host, url.port)
  https.use_ssl = true

  request = Net::HTTP::Get.new(url)
  request["Bptoken"] = "" # Add your key here
  form_data = []
  request.set_form form_data, 'multipart/form-data'
  response = https.request(request)
  # puts response.read_body
  @data =  JSON.parse(response.body)['data']

  pdfurl = ''
  CSV.open("contacts.csv", "wb") do |csv|
    @data.each do |item|
      if(item['Contacts'])
        @contacts = item['Contacts']
      else
        next
      end
      # csv << @contacts.first.keys
      @contacts.each do |contact|

         # puts contact
        csv << contact.values
        pdfurl =  contact['Link']
         name = contact['FirstName'] + contact['Surname']
         pdfurl =  CGI::parse(URI::parse(pdfurl).query)
         # puts pdfurl
         contactid = pdfurl['ContactID'].to_s
         proposalid = pdfurl['ProposalID'].to_s

         pdfurlstart = 'https://betterproposals.io/proposal/pdf-output.php?ProposalID= '
         pdfurlmiddle = '&ContactID='
         pdfurlend = '&pdf-view=1'

         pdf = pdfurlstart + proposalid.to_s + pdfurlmiddle + contactid.to_s + pdfurlend

         url = URI(pdf)

         https = Net::HTTP.new(url.host, url.port)
         https.use_ssl = true

         request = Net::HTTP::Get.new(url)
         request["Cookie"] = "PHPSESSID=97pcot5ipa304gudtc1079l5k3"

         response = https.request(request)
         # puts response.read_body

         open("pdfs/" + name + ".pdf", "wb") { |file|
           file.write(response.read_body)
         }

      end
    end
  end


    CSV.open("bp.csv", "wb") do |csv|
      csv << @data.first.keys
      @data.each do |hash|
        csv << hash.values
      end
    end

  #   pagenumber = pagenumber + 1
  #
  # end



