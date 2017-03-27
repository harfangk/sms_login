require 'rails/generators/base'

module SmsLogin
  class SessionsControllerGenerator < Rails::Generators::Base
    source_root File.expand_path("../templates", __FILE__)

    def create_sessions_controller
      create_file "app/controllers/sms_login/sessions_controller.rb", sessions_controller_content
    end

    def sessions_controller_content
      %q{
class SmsLogin::SessionsController < ApplicationController
  include SmsLogin::SmsLoginHandler
  
  def sign_in
    if sign_in_with_sms_login_token
      render plain: "로그인에 성공했습니다."
    else
      render plain: "로그인에 실패!"
    end
  end
end
      }
    end
  end
end
