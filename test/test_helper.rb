require 'rubygems'
require 'test/unit'
gem 'thoughtbot-shoulda'
require 'shoulda'
gem 'thoughtbot-factory_girl'
require 'factory_girl'
require 'active_record'
require 'active_support'
require 'action_controller'

require 'yaacl'

config = YAML::load(IO.read(File.dirname(__FILE__) + '/../database.yml'))
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
ActiveRecord::Base.establish_connection(config['test'])

::YAACLPerm = YAML::load(File.open(File.dirname(__FILE__) + '/../defaults/permissions.yml.default'))
::YAACLActions = []
YAACLPerm.each_value { |roles| roles.each_value { |role| role[:actions].each {|action| YAACLActions << action unless YAACLActions.include?(action)} if role[:actions]}}


def rebuild_model
  ActiveRecord::Base.connection.create_table :posts, :force => true do |table|
    table.column :title, :string
    table.column :blog_id, :integer
    table.column :author_id, :integer
    table.column :coauthors_ids, :string, :default => ''
    table.column :proofreaders_ids, :string, :default => ''
    table.column :translators_ids, :string, :default => ''
  end
  ActiveRecord::Base.connection.create_table :blogs, :force => true do |table|
    table.column :title, :string
    table.column :founder_id, :integer
    table.column :contributors_ids, :string, :default => ''
  end
  
  ActiveRecord::Base.connection.create_table :users, :force => true do |table|
    table.column :name, :string
    table.column :global_roles_list, :string, :default => ''
  end
  
  ActiveRecord::Base.connection.create_table :roles, :force => true do |table|
    table.column :user_id, :integer
    table.column :entity_type, :string    
    table.column :entity_id, :integer
    table.column :role, :string
  end
  rebuild_classes
end

def rebuild_classes
  ActiveRecord::Base.send(:include, YAACL::Model)
  Object.send(:remove_const, "Post") rescue nil
  Object.const_set("Post", Class.new(ActiveRecord::Base))
  Post.class_eval do
    defend_this :parent => :blog, :roles => [:author, :coauthors, :translators, :proofreaders]
    belongs_to :blog
  end
  Object.send(:remove_const, "Blog") rescue nil
  Object.const_set("Blog", Class.new(ActiveRecord::Base))
  Blog.class_eval do
    defend_this :roles => [:founder, :contributors]
  end
  
  Object.send(:remove_const, "User") rescue nil
  Object.const_set("User", Class.new(ActiveRecord::Base))
  User.class_eval do
    include YAACL::User
  end
  
  Object.send(:remove_const, "Role") rescue nil
  Object.const_set("Role", Class.new(ActiveRecord::Base))
  Role.class_eval do
    include YAACL::Role
  end
end

class Anonym
  include YAACL::Anonym
end

# class Post
#   include YAACL::Model
# end
# 
# class Blog
#   include YAACL::Model
# end
# 
# class User
#   include YAACL::User
# end
# 
# class Role
#   include YAACL::Roles
# end

