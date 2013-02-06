unless Identity.where(code:"admin").exists?
  identity= Identity.create :code => "admin", :email => "admin@test.com", :password => "secret",
    :password_confirmation => "secret"
  User.create :provider => "identity", :uid => identity.id.to_s, :code => identity.code,
    :email => identity.email, :role => "M,A,D"
end
