class AddYaaclFields < ActiveRecord::Migration
  def self.up
    add_column :<%= user_model.tableize %>, :global_roles_list, :string, :default => ''	
  	
		<% models.each do |m| %><% m[:roles].each do |r| %><% if r.pluralize == r %>add_column :<%= m[:name].tableize %>, :<%= "#{r}_ids" %>, :string, :default => ''
		<% else %>add_column :<%= m[:name].tableize %>, :<%= "#{r}_id" %>, :integer<% end %>    
  	<% end %><% end %>
		create_table :roles do |t|
			t.column :user_id, :integer
	    t.column :entity_type, :string    
	    t.column :entity_id, :integer
	    t.column :role, :string
	  end
		add_index :roles, :user_id
		add_index :roles, [:entity_type, :entity_id]
	end

  def self.down
    remove_index :roles, :user_id
    remove_index :roles, [:entity_type, :entity_id]
		drop_table :roles
		remove_column :<%= user_model.tableize %>, :global_roles_list
  	
		<% models.each do |m| %><% m[:roles].each do |r| %><% if r.pluralize == r %>remove_column :<%= m[:name].tableize %>, :<%= "#{r}_ids" %>
		<% else %>remove_column :<%= m[:name].tableize %>, :<%= "#{r}_id" %><% end %>    
  	<% end %><% end %>
  end
end
