class Mindapp::Notice
  include Mongoid::Document
  include Mongoid::Timestamps
  field :message, :type => String
  field :unread, :type => Boolean
  belongs_to :user

  def self.recent(user_id)
    where(unread: true, user_id: user_id).last
  end
end
