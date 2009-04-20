::YAACLPerm = YAML::load(File.open("#{RAILS_ROOT}/config/perm.yml"))
::YAACLActions = []
YAACLPerm.each_value { |roles| roles.each_value { |role| role[:actions].each {|action| YAACLActions << action unless YAACLActions.include?(action)} if role[:actions]}}

require 'yaacl'

ActionController::Base.class_eval do
  include YAACL::Controller
end

ActiveRecord::Base.class_eval do
  include YAACL::Model
end