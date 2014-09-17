NS = {
  'premis' => 'info:lc/xmlns/premis-v2'
}

Given /^I want to describe a (file|url)$/ do |thing|
  @thing = thing

  pic = File.join(File.dirname(__FILE__), '..', 'fixtures', "wip.png")
  
  case thing
  when "file"  
    @file = Rack::Test::UploadedFile.new(pic, 'image/png', true)
  when "url"
    @url = "http://localhost:4000/wip.png"
  end


end

Given /^I provide an object identifier and an ieid$/ do
  @id_type = "URI"
  @id_value = "info:fcla/code/pim/wip.png"
  
  @ieid_type = "URI"
  @ieid_value = "info:fcla/code/pim"
end

When /^I press describe$/ do
  
  case @thing
  when 'file'
    post '/describe/results', { 'document' => @file, 
      'id_type' => @id_type,
      'id_value' => @id_value,
      'ieid_type' => @ieid_type,
      'ieid_value' => @ieid_value 
    }
  when 'url'
      get '/describe/results', { 'document' => @url, 
        'id_type' => @id_type,
        'id_value' => @id_value,
        'ieid_type' => @ieid_type,
        'ieid_value' => @ieid_value 
      }

    end

  end

Then /^it should have an object with an object identifier that matches my input$/ do
  doc = LibXML::XML::Parser.string(last_response.body).parse
  expect(doc.find_first('//premis:objectIdentifierType', NS).content).to eql("URI")
  expect(doc.find_first('//premis:objectIdentifierValue', NS).content).to eql("info:fcla/code/pim/wip.png")
end

Then /^it should have an IEID that matches my input$/ do
  doc = LibXML::XML::Parser.string(last_response.body).parse
  expect(doc.find_first('//premis:linkingIntellectualEntityIdentifierType', NS).content).to eql("URI")
  expect(doc.find_first('//premis:linkingIntellectualEntityIdentifierValue', NS).content).to eql("info:fcla/code/pim")
end

Then /^all linking objects should have matching identifiers$/ do
  doc = LibXML::XML::Parser.string(last_response.body).parse
  expect(doc.find_first('//premis:linkingObjectIdentifierType', NS).content).to eql("URI")
  expect(doc.find_first('//premis:linkingObjectIdentifierValue', NS).content).to eql("info:fcla/code/pim/wip.png")
end

Given /^I don't provide the object identifier type$/ do
  @id_value = "info:fcla/code/pim/wip.png"
  @id_type = nil
end

Then /^I should get an error$/ do
  expect(last_response.status).to eql 400
end

Given /^I don't provide the object identifier value$/ do
  @id_type = "URI"
  @id_value = nil 
end

Then /^it should have an originalName that matches the upload filename or url$/ do
    doc = LibXML::XML::Parser.string(last_response.body).parse
    expect(doc.find_first('//premis:originalName', NS).content).to eql case @thing
      when 'file'
        "wip.png"
      when 'url'
        'http://localhost:4000/wip.png'
      end
end

Given /^I want to describe a pdf file$/ do
  @thing = 'file'
  f = File.join(File.dirname(__FILE__), '..', 'fixtures', "00001.pdf")
  @file = Rack::Test::UploadedFile.new(f, 'application/pdf', true)
  
end

Then /^The bitstream ids should be correct$/ do
  
  # one file object
  doc = LibXML::XML::Parser.string(last_response.body).parse
  file_objects = doc.find "//premis:object[@xsi:type='file']", NS
  expect(file_objects).to have(1).items
  f_type = file_objects.first.find_first('premis:objectIdentifier/premis:objectIdentifierType', NS).content.strip
  expect(f_type).to_not be_empty
  f_value = file_objects.first.find_first('premis:objectIdentifier/premis:objectIdentifierValue', NS).content.strip
  expect(f_value).to_not be_empty
  
  # should be identified
  bs_objects = doc.find "//premis:object[@xsi:type='bitstream']", NS
  expect(bs_objects).to have_at_least(1).items
  bs_ids = bs_objects.map do |bs_o|
    b_type = bs_o.find_first('premis:objectIdentifier/premis:objectIdentifierType', NS).content.strip
    expect(b_type).to_not be_empty
    b_value = bs_o.find_first('premis:objectIdentifier/premis:objectIdentifierValue', NS).content.strip
    expect(b_value).to_not be_empty
    [b_type, b_value]
  end

  # should be no dups
  expect(bs_ids.size).to eql bs_ids.uniq.size

  # should start with the file they belong to
  bs_ids.each do |type, value|
    expect(type).to eql f_type
    expect value =~ %r{^#{f_value}.+$}
  end

  # relationship ids should match links
  file_links = doc.find "//premis:object[@xsi:type='file']/premis:relationship/premis:linkingObject", NS
  expect(file_links).to have(0).items
end

