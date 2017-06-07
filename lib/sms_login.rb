require 'securerandom'

module SmsLogin
  class SmsLogin
    def self.parse_phone_nunmber(input_phone_number)
      input_phone_number.delete("^0-9")
    end

    def self.find_user_with_phone_number(phone_number)
      if phone_number.empty?
        return false
      end

      User.find_or_create_by(phone: phone_number)
    end

    def self.handle_mobile_devices(record, parsed_phone_number, root_url)
      token = new_token
      record.update(sms_login_token: token, sms_login_token_created_at: Time.now.getgm)
      msg = sms_login_token_msg(token, root_url)
      SmsSender.send_message(parsed_phone_number, msg)
    end

    def self.new_token(length=20)
      rlength = (length * 3) / 4
      SecureRandom.urlsafe_base64(rlength).tr('lIO0', 'sxyz')
    end

    def self.sms_login_token_msg(token, root_url)
      "다음 링크를 클릭하시면 로그인할 수 있습니다: #{root_url}?sms_login_token=#{token}"
    end

    def self.handle_other_devices(record, parsed_phone_number)
      login_code = new_login_code
      record.update(sms_login_code: login_code, sms_login_code_created_at: Time.now.getgm)
      msg = sms_login_code_msg(login_code)
      SmsSender.send_message(parsed_phone_number, msg)
    end

    def self.new_login_code(length=3)
      SecureRandom.hex(length)
    end

    def self.sms_login_code_msg(login_code)
      "로그인 코드: #{login_code}"
    end
  end
end
