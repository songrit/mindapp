class User
  include Mongoid::Document
  field :provider, :type => String
  field :uid, :type => String
  field :code, :type => String
  field :email, :type => String
  field :role, :type => String
  belongs_to :identity, :polymorphic => true, :optional => true
  has_many :xmains, :class_name => "Mindapp::Xmain"

  def has_role(role1)
    return role.upcase.split(',').include?(role1.upcase)
  end
  def self.from_omniauth(auth)
    where(:provider=> auth["provider"], :uid=> auth["uid"]).first || create_with_omniauth(auth)
  end
  def self.create_with_omniauth(auth)
    identity = Identity.find auth.uid
    create! do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.code = identity.code
      user.email = identity.email
      user.role = "M"
    end
  end
  def secured?
    role.upcase.split(',').include?(ma_secured_ROLE)
  end
end
