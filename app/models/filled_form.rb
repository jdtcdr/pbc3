class FilledForm < ActiveRecord::Base
  belongs_to :form
  belongs_to :user
  belongs_to :payment
  has_many :filled_fields, :autosave => true, :dependent => :destroy,
    :include => :form_field, :order => 'form_fields.form_index'
  
  validates :form, :presence => true
  validates :user, :presence => true
  validates :name, :presence => true
  
  def payable_amount
    filled_fields.includes(:form_field).where('form_fields.monetary' => true).map{|ff| ff.payable_amount}.inject(:+)
  end
  
end
