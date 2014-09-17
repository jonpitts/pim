Given /^I submit an? (well|ill)-formed document$/ do |state|
  @doc = case state
         when 'well'
           fixture_data 'pim_container.xml'
         when 'ill'
           fixture_data 'not_well_formed.xml'
         end
end

When /^I press validate$/ do
  post '/validate/results', :document => @doc 
end

Then /^a result document should be returned$/ do
  expect(last_response.status).to eql 200
  #puts last_response.body
  expect(last_response).to have_selector('h1') do |tag|
    expect(tag.text).to match /Results/
  end
  
end

Then /^it should contain (no|some) formedness errors$/ do |quantity|

  case quantity
  when 'no'
    expect(last_response.body).to have_selector('h2', :content => 'Document is well-formed')
    
  when 'some'
    expect(last_response.body).to have_selector('h2', :content => 'Document is not well-formed:')
    expect(last_response.body).to have_selector('code')
    
  end

end
