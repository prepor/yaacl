module YAACL::Model
  def self.included(base)
    base.extend ClassMethods
  end 

  module ClassMethods
    
    def defend_this(options = {})
      str = %{
        write_inheritable_attribute :yaacl_options, {:name => self.name.downcase.to_sym}.merge(options)
        class_inheritable_reader :yaacl_options
        }
        
        options[:roles].each do |role|
          str << if self.column_names.include?(role.to_s + '_id')
            %{
              belongs_to :#{role.to_sym}, :class_name => '#{YAACL.options[:user_model]}'
              }
          else              
            %{
              has_many :#{role.to_sym}_roles, 
                     :as => :entity, 
                     :conditions => {:role => "#{role.to_s.singularize}"}, 
                     :class_name => '#{YAACL.options[:role_model]}'
                     
            has_many :#{role.to_sym}, :class_name => '#{YAACL.options[:user_model]}', 
                                  :through => :"#{role.to_sym}_roles",
                                  :source => :user do
                def <<(us)
                  us.add_role :"#{role.to_s.singularize}", proxy_owner
                end
              end
            }
          end
        end if options[:roles]
          
        str << %{include YAACL::Model::InstanceMethods}

        class_eval str
      if options[:roles]
        options[:roles].each do |role|
          # debugger
          unless self.column_names.include?(role.to_s + '_id')
            class_eval <<-EOV    
              def #{role}=(new_users)
                 #{role}.select{|v| !new_users.include?(v)}.each {|v| v.remove_role(:#{role.to_s.singularize}, self)}
                 new_users.select{|v| !#{role}.include?(v)}.each {|v| v.add_role(:#{role.to_s.singularize}, self)}
              end
              def #{role.to_s}_add(us)
                self.#{role.to_s}_ids = (#{role.to_s}_ids.split(',') << us.id.to_s ).join(',')
              end
              def #{role.to_s}_remove(us)
                self.#{role.to_s}_ids = #{role.to_s}_ids.split(',').delete_if{|v| v.to_i == us.id}.join(',')
              end
            EOV
          end
        end
      end          
    end
    

  end

  module InstanceMethods      

    def permit?(user_id, action)
      action = action.to_sym
      
      yaacl_options[:roles].each do |role|
        if YAACLPerm[yaacl_options[:name]][role.to_s.singularize.to_sym]
          if respond_to?((role.to_s + '_id').to_sym)
            if self.send(role.to_s + '_id') == user_id && YAACLPerm[yaacl_options[:name]][role.to_s.singularize.to_sym][:actions].include?(action)
              return true
            else
              next
            end
          end              
          role_to_array(role).select { |v| return true if v.to_i == user_id && YAACLPerm[yaacl_options[:name]][role.to_s.singularize.to_sym][:actions].include?(action)}
        end
      end 
      return true if (yaacl_options[:parent] && self.send(yaacl_options[:parent]) && self.send(yaacl_options[:parent]).permit?(user_id, action))
      false
    end
    
    def role_to_array(role)
      (self.send(role.to_s.pluralize + '_ids') || '').split(',').map{|v| v.to_i}
    end
    
    def defend_name
      yaacl_options[:name].to_s.camelize
    end
    
    def remove_roles(roles)
      YAACL.options[:role_model].constantize.delete_all "entity_type = '#{defend_name}' AND entity_id = #{self.id} AND role IN (#{roles.map {|role| "'#{role.to_s.singularize}'"}.join(',')})"
      roles.each { |role| self.send(role.to_s + '_ids=', '')}
    end
    
    def has_role?(role, user_id)
      role_to_array(role).include?(user_id)
    end
   
  
  end
end