module SmsLogin
  class MigrationGenerator < Rails::Generators::Base
    source_root File.expand_path("../templates", __FILE__)

    def migration_string
      %q(class AddSmsLoginTokenToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :sms_login_token, :string
    add_index :users, :sms_login_token
    add_column :users, :sms_login_token_created_at, :datetime
  end
end)
    end

    def create_migration
      create_file "db/migrate/#{Time.now.getgm.strftime("%Y%m%d%H%M%S")}_add_sms_login_token_to_user.rb", migration_string
    end
  end
end
