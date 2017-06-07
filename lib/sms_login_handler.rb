module SmsLogin
  module SmsLoginHandler
    def lookup_cellphone_number
      url = sms_login_sessions_sign_in_url
      phone_number = params[:user][:phone_number]
      success = SmsLogin.process_phone_number(phone_number, url)
      if success
        render plain: "SMS로 로그인용 링크가 발송되었습니다. 확인해주세요. \n #{success}"
      else
        render plain: "입력해주신 전화번호를 찾을 수 없습니다."
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
        false
      end
    end

    def sign_in_with_sms_login_code
      user = User.find_by(sms_login_code: params[:sms_login_code])
      if user && (user.sms_login_code_created_at - Time.now.getgm) < (60 * 2)
        if defined?(Devise)
          replace_devise_credential_with(user)
        else
          session[:user_id] = user.id
        end
      else
        false
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
