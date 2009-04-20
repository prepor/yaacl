module YAACL::User
  def self.included(base)
    base.class_eval do
      include YAACL::User::InstanceMethods
      has_many :entities_roles_global, :conditions => ['entity_type = ?', 'Global'], :class_name => YAACL::options[:role_model]
      has_many :entities_roles, :class_name => YAACL::options[:role_model]
      after_create :add_user_role
    end
  end
  module InstanceMethods 
    def permit?(action_name, entity = nil)                
      return true unless action_exists?(action_name)
      global_permit?(action_name) || (entity && entity.permit?(self.id, action_name))
    end
    
    def global_permit?(action_name)
      global_roles.each { |role| return true if YAACLPerm[:global][role.to_sym][:actions] && YAACLPerm[:global][role.to_sym][:actions].include?(action_name) }
      false
    end
    
    def add_role(role_name, entity = nil)
      entities_roles.create({
        :entity_type => entity ? entity.defend_name : "Global",
        :entity_id => entity ? entity.id : nil,
        :role => role_name.to_s
      })          
      
      if entity && !entity.respond_to?((role_name.to_s + '_id').to_sym)
        entity.send(role_name.to_s.pluralize + '_ids=', (entity.send(role_name.to_s.pluralize + '_ids').empty? ? '' : entity.send(role_name.to_s.pluralize + '_ids') + ',') + self.id.to_s)
        entity.save
      elsif entity
        entity.send((role_name.to_s + '_id=').to_sym, self.id)
        entity.save
      else
        self.global_roles_list = (global_roles << role_name).join(',')
        self.save
      end
    end
    
    def global_roles
      (global_roles_list || '').split(',')
    end
    
    def remove_role(role_name, entity = nil)
      entity_type = entity ? entity.defend_name : "Global"
      entity_id = entity ? entity.id : nil
      entities_roles.find(:first, :conditions => { :entity_type => entity_type,
        :entity_id => entity_id,
        :role => role_name.to_s}).destroy
      entities_roles.reload
      if entity && !entity.respond_to?((role_name.to_s + '_id').to_sym)
        entity.send(role_name.to_s.pluralize + '_ids=', YAACL.options[:role_model].constantize.find(:all, :conditions => {:entity_type => entity_type, :entity_id => entity_id, :role => role_name.to_s}).map{|v| v.user_id}.join(','))
        entity.save
      elsif entity
        entity.send((role_name.to_s + '_id=').to_sym, nil)
        entity.save
      else
        global_roles_list = global_roles.delete_if{|v| v == role_name.to_s}.join(',')
        save
      end
    end
    
    def action_exists?(action_name)             
      YAACLActions.include?(action_name.to_sym)
    end
    
    def add_user_role
      add_role 'user'
    end
    
    def admin?
      global_roles.include?('admin')
    end
  
  end
end