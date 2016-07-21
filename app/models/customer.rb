class Customer < ActiveRecord::Base
  has_many :enquiries
  has_many :customer_fus

  def to_label
    to_s
  end

  def to_s
    text = ''
    if title != nil and title != ""
      text += "#{title} "
    end
    text += "#{firstname} #{lastname}"
  end
  
  def Customer.split_name(name)
    tl = ''
    fs = ''
    ls = ''
    
    if name == nil or name == ''
      return ['','','']
    end
    
    elems = name.split
    elems.collect! {|x| 
      x.strip!
      x.gsub!('.', '')
      x.capitalize! unless x == 'and'
      x
    } 
      
    titles = ['dr', 'mr', 'mrs', 'ms', 'sir', 'prof', 'rev', 'revd', 'lord', 'lady', 'and' ]
    while titles.include?(elems[0].downcase)
      tl += elems.shift + " "
    end
    tl.strip!
            
    if elems.size == 1
      ls = elems[0]
    else
      ls = elems.pop
      fs = elems.join(' ')
    end
    
    return [tl, fs, ls]
  end  
end