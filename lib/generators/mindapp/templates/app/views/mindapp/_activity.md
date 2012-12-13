<%- code, name = activity['TEXT'].split(':',2) %>
##### งาน <%= service.name %> ขั้นตอนที่ <%= j %> <%= name %>
<%- img_file= "#{Rails.root}/app/views/#{service.module}/#{service.code}/#{code}.png" %>
<%- if File.exist?(img_file)%>
  <%- img = Base64.encode64(File.read(img_file)) %>
  <img src="data:image/png;base64,<%= img %>">
<%- end %>
<%- md_file= "#{Rails.root}/app/views/#{service.module}/#{service.code}/#{code}.md" %>

<%= File.read md_file if File.exist?(md_file) %>
