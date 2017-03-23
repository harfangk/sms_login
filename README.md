# sms_login

SMS로 로그인 토큰을 포함한 링크를 전송해서 비밀번호 없이 그 링크를 통해
로그인할 수 있도록 해주는 젬입니다.

## 사용법

`Gemfile`에 `gem 'sms_login', github: 'harfangk/sms_login'`를 추가해주세요.

`User` 모델에 `phone` 필드가 존재해야 합니다. 현재 동작을 위해서는 다음 세 요소가 필요합니다.

* 세션 컨트롤러 
* 루트 
* User 모델 토큰 관련 마이그레이션 

```ruby
# db/migrate/YYYYmmddHHMMSS_add_sms_login_token_to_user.rb
class AddSmsLoginTokenToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :sms_login_token, :string
    add_index :users, :sms_login_token
    add_column :users, :sms_login_token_created_at, :datetime
  end
end

# app/controllers/sms_login/sessions_controller.rb
require 'sms_login_handler.rb'
require 'sms_login.rb'

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

# config/routes.rb
Rails.application.routes.draw do
  ...

  namespace :sms_login do
    namespace :sessions do
      post :lookup_cellphone_number, as: 'lookup'
      get :sign_in
      delete :sign_out_from_sms_login, as: 'sign_out'
    end
  end

  ...
end
```

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
