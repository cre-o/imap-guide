# Populate roles
ActiveRecord::Base.transaction do
  Role.delete_all

  Role.create! id: 1, name: 'user'
  Role.create! id: 2, name: 'admin'
end

# Create admin user
ActiveRecord::Base.transaction do
  User.create! name: 'admin', surname: 'admin',
    role: Role.find_by(name: 'admin'),
    email: Rails.application.secrets.admin['email'],
    password: Rails.application.secrets.admin['password']
end


