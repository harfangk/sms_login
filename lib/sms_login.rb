module SmsLogin
  class SmsLogin
    def self.process_phone_number(input_phone_number, root_url)
      parsed_phone_number = parse_phone_nunmber(input_phone_number)
      record = find_user_with_phone_number(parsed_phone_number)
      respond_to_record(record, parsed_phone_number, root_url)
    end

    def self.parse_phone_nunmber(input_phone_number)
      input_phone_number.delete("^0-9")
    end

    def self.find_user_with_phone_number(phone_number)
      User.find_by(phone: phone_number)
    end

    def self.respond_to_record(record, parsed_phone_number, root_url)
      if record 
        token = SmsLogin.new_token
        msg = sms_login_msg(token, root_url)
        record.update(sms_login_token: token, sms_login_token_created_at: Time.now.getgm)
        SmsSender.send_message(parsed_phone_number, msg)
        msg
      else
        false
      end
    end

    def self.sms_login_msg(token, root_url)
      "다음 링크를 클릭하시면 로그인할 수 있습니다: #{root_url}?sms_login_token=#{token}"
    end

    def self.new_token(length=20) 
      rlength = (length * 3) / 4
      SecureRandom.urlsafe_base64(rlength).tr('lIO0', 'sxyz')
    end
  end
end
