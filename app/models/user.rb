class User < ActiveRecord::Base

  def self.with_omniauth(auth)
    where(auth.slice(:provider, :uid)).first_or_create do |user|
      user.provider = auth.provider
      user.uid      = auth.uid
      user.name     = auth.info.name
      user.email    = auth.info.email
      user.username = auth.info.nickname
      user.avatar   = auth.extra.raw_info.avatar_url
    end
  end

end
