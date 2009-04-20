yaacl_config_path = "#{RAILS_ROOT}/config/permissions.yml"
if File.exists?(yaacl_config_path)
  ::YAACLPerm = YAML::load(File.open(yaacl_config_path))
  ::YAACLActions = []
  YAACLPerm.each_value { |roles| roles.each_value { |role| role[:actions].each {|action| YAACLActions << action unless YAACLActions.include?(action)} if role && role[:actions]}}

  require 'yaacl'

  ActionController::Base.class_eval do
    include YAACL::Controller
  end

  ActiveRecord::Base.class_eval do
    include YAACL::Model
  end
end