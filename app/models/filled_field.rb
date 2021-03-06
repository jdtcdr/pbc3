class FilledField < ActiveRecord::Base
  belongs_to :filled_form
  belongs_to :form_field
  
  attr_protected :id
  
  validates :filled_form, :presence => true
  validates :form_field_id, :presence => true,
    :uniqueness => {:scope => :filled_form_id}
  
  def payable_amount
    case form_field.field_type
      when FormField::FIELD
        value.to_money
      when FormField::SINGLE_CHOICE
        value.to_money
      when FormField::MULTIPLE_CHOICE
        value.split(',').map{|v| v.to_money}.inject(:+)
      when FormField::COUNT
        (value.to_i * form_field.value.to_i).to_money
      else
        0.to_money
    end
  end
  
end
