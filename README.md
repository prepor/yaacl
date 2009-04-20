About
====

Yet Another Access Control List. With permissions inheritance and 0 sql requests for check permissions.

Usage
====

Install

	./script/plugin install git://github.com/preprocessor/yaacl.git

Create migration

	./script/generate yaacl User Post:author:coauthors Blog:founder:contributors
	
This will add roles author and coauthors to posts table, founder and contributors roles to blogs table and global_roles_list field to users table.

Models:

	class Post < ActiveRecord::Base
	  defend_this :parent => :blog, :roles => [:author, :coauthors]
	  belongs_to :blog
	end
	
	class Blog do
    defend_this :roles => [:founder, :contributors]
	end

	class User
    include YAACL::User
	end

Controller:

	class PostsController < ApplicationController
		before_filter :load_blog
		before_filter :load_post, :only => [:show, :edit, :update, :destroy]
		defend_this :entities => [:post, :blog]
		
		def	new
			... bla bla bla
		end
		
		def	destroy
			... bla bla bla
		end
		
		def load_post
			@post = Post.find(params[:id])			
		end
		
		def load_blog
			@blog = Blog.find(params[:blog_id])			
		end
		
		
		# I think this will be in your ApplicationController
		
		def	access_denied
			redirect_to new_sessions_path
		end
		
		def	current_user
			User.find(session[:user_id])
		end
	end

If action not permitted will be called 'access_denied' method.

For define permissions edit config/permissions.yml file.

In this example before call 'destroy' action, YAACL check permissions for user in post object, blog object and at global level. Access will allow if user is author of post OR founder of blog OR admin.

YAACL will generate belongs_to and has_many association for all of yours roles. So you can access to author via @post.author and coauthors via @post.coauthors. But DON'T add roles via association's << or 'create' methods. Use current_user.add_role instead.

Add roles
----

	current_user.add_role :admin # for global roles
	current_user.add_role :coauthor # for roles in entity
	
Check roles
----

	current_user.permit? :buttons_push # for roles which only at global level
	current_user.permit? :posts_edit, @post # will check permissions in blog, post and global level

Options
====

defend_this in model:

:roles — array of roles in model. for single role (author) table must has %role%_id field, for plural role (:coauthors) table must has %role%_ids field of string type with :default => ''

:name — name of entity used in module e.g. in News model :name => :post

:parent — name of parent model e.g. :post for Comment, :blog for Post. Model must have method with this name and it should return AR object of class with defend_this. Usually this simply belongs_to association.

:user_model — by default 'User'

:role_model — by default 'Role'

defend_this in controller: 

:name — name of entity used in module e.g. in News controller :name => :posts

:user_object — method name of current user. By default 'current_user'

:entities — list of instance variables (@) which must be preloaded to check permissions for existed var. E.g. :entities => [:post, :blog] for 'show' action will check current_user.permit?(:posts_show, @post) and for index 'new' current_user.permit?(:posts_new, @blog)

Notes
====

You can define defend_%action_name% method in controller. If it return false will be called access_denied without next checks.

You can use common behaviour for anonymous user. Simply current_user must return object of class liki this:

	class Anonym
	  include YAACL::Anonym
	end
	
If action is not defined in permissions.yml it always allow.

ToDo
====

normal english :)