<%- d= Nokogiri::XML(service.xml) %>
<%- if service.code=="link" %>
#### งาน<%= service.name.split(':')[0] %>
  <%- if !(d/'node/node').blank? && (d/'node/node')[0]['TEXT'] %>
<%= uncomment (d/'node/node')[0]['TEXT'] %>
  <%- end %>
<%- else %>
#### งาน<%= service.name %>
  <%- md_file= "#{Rails.root}/app/views/#{service.module.code}/#{service.code}.md" %>

  <%= File.read md_file if File.exist?(md_file) %>
  <%- j= 1 %>
  <%- (d/'/node/node').each do |activity| %>
    <%- next unless (activity/'icon')[0] %>
    <%- action= freemind2action((activity/'icon')[0]['BUILTIN']) %>
    <%- next unless (action=='form') %>
    <%= render :partial=>'mindapp/activity.md', :locals=>{:activity=>activity, :j=>j, :service=>service}  %>
    <%- j= j + 1 %>
  <%- end %>
<%- end %>

<!--%= #code_div File.read(model_file) %-->

<!--%= # code_div model.camelize.constantize.columns.to_yaml %-->
