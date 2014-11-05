class Identity
  include Mongoid::Document
  include OmniAuth::Identity::Models::Mongoid
  self.auth_key 'code'

  field :code, :type => String
  field :email, :type => String
  field :password_digest, :type => String

  validates_presence_of :code
  validates_uniqueness_of :code
  validates_uniqueness_of :email
  # validates_format_of :email, :with => /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i
end
