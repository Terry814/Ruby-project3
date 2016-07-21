class CustomerFu < ActiveRecord::Base
  belongs_to :customer
  has_many :enquiries
  
  def fu_id
    id()
  end
end