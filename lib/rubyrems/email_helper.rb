# Intended as a Mixin this has routines to help with loading emails and parsing them
# 1/9/10

module EmailHelper
  
  
  # extract the whole of the relevant body part
  def getKeyContent(bdy)
    spec_re = Regexp.new(/.*Client Details:(.*)An enquiry from.*/m)

    kc = ""

    matchdata = spec_re.match(bdy)
    kc = matchdata[1].strip if matchdata
    return [kc, 'specific']
  end
end
