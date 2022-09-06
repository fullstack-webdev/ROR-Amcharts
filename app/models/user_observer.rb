class UserObserver < ActiveRecord::Observer
    cattr_accessor :current_user


end
