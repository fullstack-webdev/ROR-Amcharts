task :create_fake_data => :environment do
    puts "Starting..."
    FakeData.new.create_fake_data
end