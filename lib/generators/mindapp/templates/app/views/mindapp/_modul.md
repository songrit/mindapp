
### ระบบงาน<%= modul.name %>

<%- controller_file= "#{Rails.root}/app/controllers/#{modul.code}_controller.rb" %>
<%- md_file= "#{Rails.root}/app/controllers/#{modul.code}.md" %>

<%= File.read md_file if File.exist?(md_file) %>

<%= render :partial=>'mindapp/service.md', :collection=> modul.services.asc(:seq) %>
