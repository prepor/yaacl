module YAACL::Role
  def self.included(base)
    base.class_eval do
      named_scope :global, :conditions => { :entity_type => 'Global' }
      belongs_to :user, :class_name => YAACL::options[:user_model]
      belongs_to :entity, :polymorphic => true
    end
  end
end