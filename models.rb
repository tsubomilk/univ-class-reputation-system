require "bundler/setup"
Bundler.require 

ActiveRecord::Base.establish_connection

class User < ActiveRecord::Base
    has_secure_password
    has_many :tasks
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