
### <%= model %>

<% model_file= "#{Rails.root}/app/models/#{model}.rb" %>
<%= code_div File.read(model_file) %>
