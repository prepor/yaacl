module YAACL::Controller
  def self.included(base)
    base.extend ClassMethods
    base.send(:include, InstanceMethods) 
  end

  module ClassMethods
    def defend_this(options = {})
      write_inheritable_attribute :yaacl_options, options
      class_inheritable_reader :yaacl_options
      class_eval do            
        before_filter :check_permissions
      end
    end
  end

  module InstanceMethods
    def check_permissions
      defend_controller_name = yaacl_options[:controller] ? yaacl_options[:controller] : controller_name
      entity = current_entity yaacl_options[:entities]
      is_defined_method = self.respond_to?(("defend_#{params[:action]}").to_sym)
      access_denied unless ((is_defined_method && self.send(("defend_#{params[:action]}").to_sym)) || (!is_defined_method && current_user.permit?((defend_controller_name + '_' + params[:action]).to_sym, entity)))
    end  
    
    def current_entity(entities)
      return nil unless entities
      entities.each do |entity|
        return instance_variable_get(('@' + entity.to_s).to_sym) if instance_variable_defined?(('@' + entity.to_s).to_sym)
      end
      nil
    end 
  end
end