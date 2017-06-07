require 'securerandom'

module SmsLogin
  def send_sms(user, phone_number)
    if request.user_agent =~ /Mobi/
      handle_mobile_devices(user, phone_number, sms_login_sessions_token_sign_in_url)
      redirect_to sms_login_sessions_token_sign_in_info_url
    else
      handle_other_devices(user, phone_number)
      save_phone_number_in_session(phone_number)
      redirect_to sms_login_sessions_code_sign_in_form_url
    end
  end

  def save_phone_number_in_session(phone_number)
    session[:phone_number] = phone_number
  end

  def sign_in_with_sms_login_token(token)
    user = User.find_by(sms_login_token: token)
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

  def sign_in_with_sms_login_code(code, phone_number)
    user = User.find_by(sms_login_code: code, phone: phone_number)
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

  def parse_phone_number(input_phone_number)
    input_phone_number.delete("^0-9")
  end

  def find_user_with_phone_number(phone_number)
    if phone_number.empty?
      return false
    end

    User.find_or_create_by(phone: phone_number)
  end

  def handle_mobile_devices(record, parsed_phone_number, root_url)
    token = new_token
    record.update(sms_login_token: token, sms_login_token_created_at: Time.now.getgm)
    msg = sms_login_token_msg(token, root_url)
    SmsSender.send_message(parsed_phone_number, msg)
  end

  def new_token(length=20)
    rlength = (length * 3) / 4
    SecureRandom.urlsafe_base64(rlength).tr('lIO0', 'sxyz')
  end

  def sms_login_token_msg(token, root_url)
    "다음 링크를 클릭하시면 로그인할 수 있습니다: #{root_url}?sms_login_token=#{token}"
  end

  def handle_other_devices(record, parsed_phone_number)
    login_code = new_login_code
    record.update(sms_login_code: login_code, sms_login_code_created_at: Time.now.getgm)
    msg = sms_login_code_msg(login_code)
    SmsSender.send_message(parsed_phone_number, msg)
  end

  def new_login_code(length=3)
    SecureRandom.hex(length)
  end

  def sms_login_code_msg(login_code)
    "로그인 코드: #{login_code}"
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
