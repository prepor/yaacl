module YAACL
  require 'yaacl/user'
  require 'yaacl/controller'
  require 'yaacl/model'
  require 'yaacl/role'
  require 'yaacl/anonym'
  class << self
    def options
      @@options ||= {}
      {:user_model => 'User', :role_model => 'Role'}.merge(@@options)
    end
    def options=(params = {})
      @@options = params
    end
    
    def users_table
      options[:user_model].tableize
    end
    
    def roles_table
      options[:role_model].tableize
    end
  end
  
end