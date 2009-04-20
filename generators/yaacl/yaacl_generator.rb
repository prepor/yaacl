class YaaclGenerator < Rails::Generator::NamedBase
  attr_accessor :models, :user_model
 
  def initialize(args, options = {})
    super
    @user_model, str_models = args[0], args[1..-1]
    @models = str_models.map do |m|
      name, *roles = m.split(':')
      {:name => name, :roles => roles}
    end
    
  end
  def manifest
    record do |m|
      m.migration_template(
        'add_yaacl_fields.rb', 'db/migrate', :migration_file_name => "add_yaacl_fields"
      )      
      m.directory File.join("app", "models")
      m.file 'role_model.rb', 'app/models/role.rb'      
      
      m.file '../../../defaults/permissions.yml.default', 'config/permissions.yml'
    end
  end
end