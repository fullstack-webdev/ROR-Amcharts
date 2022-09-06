FactoryGirl.define do
    factory :user do
        name     "Michael Hartl"
        email    "michael@example.com"
        company_id 1
        password "foobar"
        password_confirmation "foobar"
    end
end