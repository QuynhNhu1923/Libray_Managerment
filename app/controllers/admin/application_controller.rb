class Admin::ApplicationController < ::ApplicationController
  before_action :authenticate_user!
  before_action :admin_user
  
end
