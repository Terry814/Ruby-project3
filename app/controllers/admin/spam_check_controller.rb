class Admin::SpamCheckController < ApplicationController
  before_filter :login_required

  active_scaffold :spam_checks
end
