module SmsLogin
  BASE_URL = "http://localhost"
  BASE_PORT = "3000"

  def parse_phone_nunmber(input_phone_number)
    input_phone_number.delete("^0-9")
  end

  def find_phone_number_from(klass, field, phone_number)
    klass.find_by(field.to_sym => phone_number)
  end

  def respond_to_record(record, parsed_phone_number, input_phone_number)
    if record
      notification_msg = "등록하신 휴대폰 번호로 로그인용 링크가 담긴 문자를 발송했으니 확인해주세요."
      SmsSender.send_message(parsed_phone_number, "")
    else
      notification_msg = "입력하신 휴대폰 번호인 #{input_phone_number}를 찾지 못했습니다."
    end
  end

  def sms_login_msg(record)
    "다음 링크를 클릭하시면 로그인할 수 있습니다: #{BASE_URL}:#{BASE_PORT}?authentication_token=#{record.authentication_token}"
  end
end
