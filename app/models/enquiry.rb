class Enquiry < ActiveRecord::Base
  belongs_to :customer
  belongs_to :inemail, :class_name => 'Email', :foreign_key => "in_email_id"
  belongs_to :outemail, :class_name => 'Email', :foreign_key => "out_email_id" 
  belongs_to :customer_fu
  
  has_many :agent_enquiries
  has_many :unmatched_recipients
  
  def to_s
    "#{customer} : #{received_at.strftime("%d-%m-%y")}:#{property} "
  end

  def to_label
    to_s
  end

end