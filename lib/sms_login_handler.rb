module SmsLogin
  module SmsLoginHandler
    def respond_to_cellphone_number
      phone_number = params[:user][:phone_number]
      parsed_phone_number = SmsLogin.parse_phone_nunmber(phone_number)
      user = SmsLogin.find_user_with_phone_number(parsed_phone_number)
      unless user
        return redirect_to(user_login_url, failure: "입력하신 전화번호를 찾을 수 없습니다.")
      end

      if request.user_agent =~ /Mobi/
        SmsLogin.handle_mobile_devices(user, parsed_phone_number, url)
        redirect_to sms_login_sessions_token_login_info_url
      else
        SmsLogin.handle_other_devices(user, parsed_phone_number, url)
        redirect_to sms_login_sessions_code_login_form_url
      end
    end

    def sign_in_with_sms_login_token
      user = User.find_by(sms_login_token: params[:sms_login_token])
      if user && (user.sms_login_token_created_at - Time.now.getgm) < (60 * 5)
        if defined?(Devise)
          replace_devise_credential_with(user)
        else
          session[:user_id] = user.id
        end
      else
        return redurect_to(user_login_url, failure: "입력된 링크에 문제가 있습니다. 다시 시도해주세요.")
      end
    end

    def sign_in_with_sms_login_code
      user = User.find_by(sms_login_code: params[:sms_login_code], phone: params[:phone])
      if user && (user.sms_login_code_created_at - Time.now.getgm) < (60 * 2)
        if defined?(Devise)
          replace_devise_credential_with(user)
        else
          session[:user_id] = user.id
        end
        redirect_to root_url, success: "환영합니다."
      else
        return redurect_to(user_login_url, failure: "입력된 코드에 문제가 있습니다. 다시 시도해주세요.")
      end
    end

    def sign_out_from_sms_login
      if defined?(Devise)
        request.env['warden'].logout
      else
        session[:user_id] = nil
      end
    end

    private 
    def replace_devise_credential_with(user)
      sign_out_of_devise
      request.env['warden'].set_user(user)
    end

    # 디바이스에서 로그아웃 용으로 사용하는 sign_out_all_scopes 메서드 소스에서 가져온 코드입니다.
    # https://github.com/plataformatec/devise/blob/master/lib/devise/controllers/sign_in_out.rb 
    def sign_out_of_devise
      request.env['warden'].logout
      session.empty?
      session.keys.grep(/^devise\./).each { |k| session.delete(k) }
      request.env['warden'].clear_strategies_cache!
    end
  end
end
