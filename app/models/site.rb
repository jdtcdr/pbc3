class Site < ActiveRecord::Base
  belongs_to :communities_page, :class_name => 'Page',
    :foreign_key => :communities_page_id
  belongs_to :about_page, :class_name => 'Page',
    :foreign_key => :about_page_id
end
