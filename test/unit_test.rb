require 'test/test_helper'

class UnitTest < Test::Unit::TestCase
  context "A Post with defend_this" do
    setup do
      rebuild_model
      @post = Post.create

      @author = User.create :name => 'Andrew'
      @coauthors = [User.create(:name => 'Max'), User.create(:name => 'Kate')]
      
    end

    should "has method author" do
      assert @post.respond_to?(:author)
    end
    
    should "has mehod coauthors" do
      assert @post.respond_to?(:coauthors)
    end
    
    should "set author by id" do
      @post.author_id = @author.id
      assert_equal @post.author, @author
    end
    
    should "set author by object" do
      @post.author = @author
      assert_equal @post.author.id, @author.id
    end
    
    should "set coathors by array" do
      @post.coauthors = @coauthors
      assert_same_elements @post.coauthors(true), @coauthors
    end
    
    should "add coauthors via <<" do
      @post.coauthors << @coauthors[0]
      @post.coauthors << @coauthors[1]
      assert_same_elements @post.coauthors(true), @coauthors
    end
    
    # should "set coauthors by ids" do
    #   @post.coauthors_ids = @coauthors.map{|v| v.id}      
    #   assert_same_elements @post.coauthors, @coauthors
    # end
    
    
    # should "set coauthors by objects" do
    #   @coauthors.each {|v| @post.coauthors << v}
    #   require 'ruby-debug'
    #   debugger
    #   assert_same_elements @coauthors.map{|v| v.id}, @post.coauthors.map{|v| v.id}
    #   # assert_equal @coauthors.map{|v| v.id}.join(','), @post.coauthors_ids
    # end
    
    context "with author and coauthors" do
      setup do        
        @author.add_role :author, @post
        @coauthors[0].add_role :coauthor, @post
        @coauthors[1].add_role :coauthor, @post
      end

      should "has one coathor after remove_role to first" do
        @coauthors[0].remove_role :coauthor, @post
        assert_contains @post.coauthors(true), @coauthors[1]
      end
      
      should "permit to author edit" do
        assert @author.permit? :posts_edit, @post
      end
      
      should "permit to coauthor edit" do
        assert @coauthors[0].permit? :posts_edit, @post
      end
      
      should "permit to author delete" do
        assert @author.permit? :posts_destroy, @post
      end
      
      should "not permit to coauthor delete" do
        assert !@coauthors[0].permit?(:posts_destroy, @post)
      end
      context "in blog" do
        setup do
          @founder = User.create :name => 'David'
          @contributor = User.create :name => 'Lisa'
          @blog = Blog.create
          @blog.founder = @founder
          @blog.contributors << @contributor
          @post.blog = @blog
        end

        should "permit to blog founder edit posts" do
          assert @founder.permit? :posts_edit, @post
        end
        
        should "permit to blog contributor edit posts" do
          assert @contributor.permit? :posts_edit, @post
        end
        
        should "permit to blog founder delete posts" do
          assert @founder.permit? :posts_destroy, @post
        end
        
        should "not permit to blog founder edit posts" do
          assert !@contributor.permit?(:posts_destroy, @post)
        end
      end
      
    end
    
    
  end
  
  context "A User" do
    setup do
      rebuild_model
      @user = User.create :name => 'Andrew'
      @post = Post.create
    end

    should "be author after add_role" do
      @user.add_role :author, @post
      assert_equal @post.author, @user
    end
    
    should "be coauthor after add_role" do
      @user.add_role :coauthor, @post
      assert_contains @post.coauthors(true), @user
    end
    
    should "permit create post" do
      assert @user.permit?(:posts_create)
    end
    
    should "not permit create blog" do
      assert !@user.permit?(:blogs_create)
    end
    
    context "author and coauthor of post" do
      setup do
        @user.add_role :author, @post
        @user.add_role :coauthor, @post
      end

      should "not be author after remove_role" do
        @user.remove_role :author, @post
        assert_equal @post.author, nil
      end
      
      should "not be coauthor after remove_role" do
        @user.remove_role :coauthor, @post
        assert_does_not_contain @post.coauthors(true), @user
      end
      
      
    end
    
  end
  
  context "A Admin" do
    setup do
      rebuild_model
      @user = User.create :name => 'Andrew'
      @user.add_role :admin
    end

    should "permit create post" do
      assert @user.permit?(:posts_create)
    end
    
    should "permit create blog" do
      assert @user.permit?(:blogs_create)
    end
  end
  
  # context "A admin" do
  #   setup do
  #     rebuild_model
  #     @user = Anonym.new
  #   end
  # 
  #   should "permit create post" do
  #     assert @user.permmit?(:posts_create)
  #   end
  #   
  #   should "permit create blog" do
  #     assert @user.permmit?(:blogs_create)
  #   end
  # end
  
    
  
end