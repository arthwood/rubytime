require 'spec_helper'

describe User do
  context 'predefined admin user' do
    subject do
      User.new(CONFIG[:admin]).tap {|i| i.password_confirmation = CONFIG[:admin][:password] }
    end
    
    it { should be_valid }
  end
end
