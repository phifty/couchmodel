require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "lib", "couch_model"))

CouchModel::Configuration.design_directory = File.join File.dirname(__FILE__), "design"

DATABASE = {
  :url                => "http://localhost:5984/test",
  :create_if_missing  => true,
  :delete_if_exists   => true,
  :push_design        => true
}.freeze unless defined?(DATABASE)

class User < CouchModel::Base

  setup_database DATABASE

  key_accessor :username
  key_accessor :email, :default => "no email"

  has_many :memberships,
           :class_name  => "Membership",
           :view_name   => :by_user_id_and_created_at,
           :query       => lambda { |created_at| { :startkey => [ self.id, (created_at || nil) ], :endkey => [ self.id, (created_at || { }) ] } }

end

class Membership < CouchModel::Base

  setup_database DATABASE

  key_accessor :created_at

  belongs_to :user, :class_name => "User"

end

def create_users_and_memberships
  @user_one = User.create :username => "user one"
  @user_two = User.create :username => "user two"
  @membership_one = Membership.create :created_at => "yesterday", :user => @user_one
  @membership_two = Membership.create :created_at => "yesterday", :user => @user_two
end
