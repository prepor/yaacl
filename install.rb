config_yaml  = File.join('.', 'config', 'permissions.yml')
default_yaml = File.join(File.join(File.dirname(__FILE__), 'defaults'), 'permissions.yml.default')
copy_file(default_yaml, config_yaml)