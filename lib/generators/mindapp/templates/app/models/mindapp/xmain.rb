# -*- encoding : utf-8 -*-
class Mindapp::Xmain
  include Mongoid::Document
  field :xid, :type => String
  # Mindapp begin
  include Mongoid::Timestamps
  belongs_to :service, :class_name => "Mindapp::Service"
  field :start, :type => DateTime
  field :stop, :type => DateTime
  field :name, :type => String
  field :ip, :type => String
  field :status, :type => String
  belongs_to :user
  field :xvars, :type => Hash
  field :current_runseq, :type => String
  # Mindapp end

  has_many :runseqs, :class_name => "Mindapp::Runseq"
  has_many :docs, :class_name => "Mindapp::Doc"
  before_create :assign_xid


  # number of xmains on the specified date
  def self.get(xid)
    find_by(xid:xid)
  end
  def assign_xid
    self.xid = Param.gen(:xid)
  end
  def self.number(d)
    all(:conditions=>['DATE(created_at) =?', d.to_date]).count
  end
  def self.search(q, page, per_page=10)
    paginate :per_page=>per_page, :page => page, :conditions =>
      ["LOWER(xvars) LIKE ?", "%#{q}%" ],
      :order=>'created_at DESC'
  end
end
