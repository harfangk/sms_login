# sms_login

SMS로 로그인 토큰을 포함한 링크를 전송해서 비밀번호 없이 그 링크를 통해 로그인할 수 있도록 해주는 젬입니다.

https://github.com/harfangk/sms_login_sample_app 에서 작동하는 샘플 앱을 받아볼 수 있습니다.

## 설치
`Gemfile`에 `gem 'sms_login', github: 'harfangk/sms_login'`를 추가해주세요.

`User` 모델에 `phone` 필드가 존재해야 합니다. 현재 동작을 위해서는 다음 세 요소가 필요합니다.

* 세션 컨트롤러 
* 루트 
* User 모델 토큰 관련 마이그레이션 

다음 명령어를 사용해서 설치하시면 됩니다.

```ruby
bin/rails generate sms_login:install
bin/rails db:migrate
```

토큰 인증 용으로 사용하는 필드는 자동 생성된 마이그레이션 파일에서 만들어 줍니다. 

## 사용법
핸드폰 번호를 제출하는 폼은 이후 `sms_login_sessions_lookup_path`에 핸드폰 번호를 `[:user][:phone_number]`
파라미터에 담아서 제출하면 되며, 다음과 같이 만들면 됩니다.

```ruby
...
<%= simple_form_for(:user, url: sms_login_sessions_lookup_path) do |f| %>
  <div class="form-group">
    <%= f.input "phone_number", label: "핸드폰 번호" %>
    <%= f.button :submit, "핸드폰 번호로 로그인", class: 'btn btn-default' %>
  </div>
<% end %>
...
```

`Devise` 젬이 로드되어 있을 경우, 이 젬은 `warden`을 사용해서 세션을 관리합니다.
