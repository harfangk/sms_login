# devise-sms-login

SMS로 로그인 토큰을 포함한 링크를 전송해서 비밀번호 없이 그 링크를 통해
로그인할 수 있도록 해주는 젬입니다.

## 사용법

`User` 모델에 `phone` 필드가 존재해야 합니다. 토큰 인증 용으로 사용하는 필드는
자동 생성된 마이그레이션 파일에서 만들어 줍니다. 다음 명령어를 사용해서
설치하시면 됩니다.

```ruby
bin/rails generate sms_login:install
bin/rails db:migrate
```

이후 `sms_login_sessions_lookup_path`에 핸드폰 번호를 `[:user][:phone_number]`
파라미터에 담아서 제출하는 폼을 통해서 로그인하시면 됩니다. 
