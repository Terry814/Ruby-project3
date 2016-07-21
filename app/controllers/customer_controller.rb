class CustomerController < ApplicationController
  layout 'customer'

  def remove
    @cust_id = params[:id]
  end

  def delete
    @cust_id = params[:cust_id]
    @cust_email = params[:cust_email]
    
    c = Customer.find(:first, :conditions => ["id = ?", @cust_id])

    if c != nil
      if c.firstname == "Removed" and c.lastname = "Customer"
        flash.now[:notice] = "Customer details already removed for - #{@cust_email}"
      else
        if @cust_email != c.email
          if params[:source] == 'customer'
            flash.now[:error] = "Sorry - Invalid email address - #{@cust_email}"
            render 'remove'
          else
            flash.now[:error] = "Sorry - Invalid id and email address combination - #{@cust_id}/#{@cust_email}"
            render 'home/remove_customer', :layout => 'application'
          end
        else
          c.title = "A"
          c.firstname = "Removed"
          c.lastname = "Customer"
          c.email = nil
          c.alt_email = nil
          c.gets_fu = false
          c.phone_home = ""
          c.phone_mobile = ""
          c.active = false
          c.save
      
          c.customer_fus.each {|fu|
            fu.email_addr = nil
            fu.greeting = nil
            fu.save
          }
      
          flash.now[:notice] = "All Customer Details Removed - #{@cust_email}"
        end
      end

    else
      if params[:source] == 'customer'
        flash.now[:error] = "Sorry - Invalid email address - #{@cust_email}"
        render 'remove'
      else
        flash.now[:error] = "Sorry - Invalid id and email address combination - #{@cust_id}/#{@cust_email}"
        render 'home/remove_customer', :layout => 'application'
      end
    end
  end
end