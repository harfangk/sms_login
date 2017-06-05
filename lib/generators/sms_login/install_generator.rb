require 'rails/generators/base'

module SmsLogin
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("../templates", __FILE__)

    def route_string
      %q(
  namespace :sms_login do
    namespace :sessions do
      post :lookup_cellphone_number, as: 'lookup'
      get :sign_in
      delete :sign_out_from_sms_login, as: 'sign_out'
    end
  end
  )
    end

    def create_sms_login
      generate "sms_login:sessions_controller"
      generate "sms_login:migration"
      route route_string
    end
  end
end
