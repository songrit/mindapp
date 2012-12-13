class Gmindapp::Doc
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, :type => String
  field :filename, :type => String
  field :content_type, :type => String
  field :data_text, :type => String
  field :url, :type => String
  field :basename, :type => String
  field :cloudinary, :type => Boolean
  belongs_to :xmain, :class_name => "Gmindapp::Xmain"
  belongs_to :runseq, :class_name => "Gmindapp::Runseq"
  belongs_to :user
  belongs_to :service, :class_name => "Gmindapp::Service" 
  field :ip, :type => String
  field :display, :type => Boolean
  field :secured, :type => Boolean

  def self.search(q, page, per_page=PER_PAGE)
    paginate :per_page=>per_page, :page => page, :conditions =>
      ["content_type=? AND data_text LIKE ? AND (secured=? OR gma_user_id=?)",
      "output", "%#{q}%", false, session[:user_id] ],
      :order=>'gma_xmain_id DESC', :select=>'DISTINCT gma_xmain_id'
  end
  def self.search_secured(q, page, per_page=PER_PAGE)
    paginate :per_page=>per_page, :page => page, :conditions =>
      ["content_type=? AND data_text LIKE ?", "output", "%#{q}%" ],
      :order=>'gma_xmain_id DESC', :select=>'DISTINCT gma_xmain_id'
  end
end
