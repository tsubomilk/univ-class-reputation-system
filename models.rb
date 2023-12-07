require "bundler/setup"
Bundler.require 

ActiveRecord::Base.establish_connection

class User < ActiveRecord::Base
  has_secure_password
  has_many :tasks
   # ユーザー名が一意であることを保証するバリデーション
  validates :name, presence: true, uniqueness: true

  # パスワードが半角英数であることを確認するバリデーション
  validates :password, presence: true,
                       length: { minimum: 4 },
                       format: { with: /\A[a-zA-Z0-9]+\z/, message: "は半角英数で入力してください" },
                       if: -> { new_record? || !password.nil? }
end



class Task < ActiveRecord::Base
    validates :title,
    presence: true
    belongs_to :user
    belongs_to :list
end

# scope :due_over, ->{ where("due_date < ?",Date.today).where(completed: [nil,false])}
# scope :had_by, ->(user){ where(user_id: user.id)

class List  < ActiveRecord::Base
    has_many :tasks
end

# models/user.rb

class User < ActiveRecord::Base
  has_secure_password
  has_many :reviews
end

# models/review.rb

class Review < ActiveRecord::Base
  belongs_to :user
end

# models/classes.rb

class Course < ActiveRecord::Base
  has_many :reviews
end