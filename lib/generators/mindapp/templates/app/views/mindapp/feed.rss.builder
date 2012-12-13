xml.instruct!             # <?xml version="1.0" encoding="UTF-8"?>
xml.comment! "a comment"  # <!-- a comment -->
xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do
  xml.title "My Atom Feed"
#  xml.subtitle h(@feed.subtitle), "type" => 'html'
  xml.link url_for( :only_path => false,
                    :controller => 'main',
                    :action => 'atom' )
  xml.updated Time.now.iso8601
  xml.author do
    xml.name "Jens-Christian Fischer"
    xml.email "jcfischer@gmail.com"
  end
  @waypoints.each do |entry|
    xml.entry do
      xml.code entry.code
      xml.title entry.name
      xml.link "href" => url_for(  :only_path => false,
                                   :controller => 'entries',
                                   :action => 'show',
                                   :id => entry )
      xml.id entry.uid
      xml.updated entry.updated_at.iso8601
      xml.summary h(entry.description)
    end
  end
end
