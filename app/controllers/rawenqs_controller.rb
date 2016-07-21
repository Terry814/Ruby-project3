require 'rubyrems/handle_enquiries'

class RawenqsController < ApplicationController
  before_filter :login_required

  # handle a single raw_enquiry
  def do_one_raw_enq
    id = params[:id]

    rec = RawEnquiry.find(id)
    
    if not rec or rec.actioned == true
      render :text => "Raw enq #{id} has already been actioned"
    else
      reh = EnquiryHandler.new
      reh.run(:single, id)
      render :text => "Sent raw enq #{id}"
    end
  end
  
  def show_path
    render :text => $:.join("<BR>") 
  end
end