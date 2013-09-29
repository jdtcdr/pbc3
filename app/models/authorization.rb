class Authorization < ActiveRecord::Base
  belongs_to :page
  belongs_to :user
  belongs_to :group
  
  validates_presence_of :page, :user
end
