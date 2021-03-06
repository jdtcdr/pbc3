class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,
    :first_name, :last_name, :name, :administrator,
    :avatar_file_name, :avatar_content_type, :avatar_file_size,
    :avatar_updated_at, :avatar,
    :portrait_file_name, :portrait_content_type, :portrait_file_size,
    :portrait_updated_at, :portrait,
    :bio, :email_confirmation
  
  has_many :contacts, :dependent => :destroy
  has_many :contact_pages, :through => :contacts, :source => :page,
    :order => 'LOWER(pages.name) ASC'
  has_many :authorizations, :dependent => :destroy
  has_many :filled_forms, :dependent => :destroy
  has_many :payments, :dependent => :destroy
  has_many :conversations, :dependent => :destroy
  has_many :users_videos, :dependent => :destroy, :class_name => 'UsersVideos'
  has_many :videos, :through => :users_videos, :source => :video
  audited :except => [:password, :password_confirmation]
  
  has_attached_file :avatar, :styles => {
      :normal => '50x',
    }
  has_attached_file :portrait, :styles => {
      :normal => '400x',
      :thumb => '50x'
    }
  
  attr_protected :id
  
  before_validation do
    split_name
  end
  
  searchable do
    text :name, :default_boost => 2
    text :email, :default_boost => 2
  end
  
  def email_confirmation
    email
  end
  
  def authorized?(user)
    user and (user.administrator? or user == self)
  end
  
  def searchable?(user)
    user and (user.administrator? or user == self)
  end
  
  def email_lists
    EmailList.find_by_address(email)
  end
  
  def split_name
    if self.name
      self.name = self.name.strip
      # Some examples to deal with:
      # John and Jane Doe
      # John A Doe MD
      # John Smith-Doe
      # Rev. John A. Doe
      # john a. doe jr.
      # j. a. doe
      # J.A. Doe
      # John van der Doe
      # John
      first_parts = []
      last_parts = []
      parts = self.name.split(' ')
      in_first = true
      while part = parts.shift
        if last_parts.empty?
          if ! first_parts.empty? and
            part.length > 1 and
            part !~ /\./ and
            part.downcase != 'and' and
            first_parts[-1].downcase != 'and' and
            first_parts[-1] !~ /^[^\.]+.\.$/
            last_parts << part
          else
            first_parts << part
          end
        else
          last_parts << part
        end
      end
      self.first_name = first_parts.join(' ')
      self.last_name = last_parts.empty? ? nil : last_parts.join(' ')
    end
  end
  
end
