module YAACL::Anonym
  include YAACL::User::InstanceMethods
  def global_roles
    ['anonymous']
  end
end