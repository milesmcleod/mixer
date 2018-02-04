class User < ApplicationRecord
  validates :email, :username, :session_token, presence: true, uniqueness: true
  validates :img_url, presence: true
  validates :password, length: { minimum: 6, allow_nil: true }

  attr_reader :password

  before_validation :ensure_session_token

  def password=(password)
    @password = password
    self.password_digest = BCrypt::Password.create(password)
  end

  def is_password?(password)
    BCrypt::Password.new(self.password_digest).is_password?(password)
  end

  def self.find_by_credentials(name, password)
    @user = User.includes(:notes, :notebooks, :tags, :taggings).find_by(email: name)
    @user ||= User.includes(:notes, :notebooks, :tags, :taggings).find_by(username: name)
    if @user && @user.is_password?(password)
      return @user
    else
      return nil
    end
  end

  def ensure_session_token
    self.session_token ||= SecureRandom.urlsafe_base64
  end

  def reset_session_token
    self.session_token = SecureRandom.urlsafe_base64
    self.save!
    self.session_token
  end

end
