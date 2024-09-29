call_logs_data = []
uid = User.first.id
1000.times do
    call_logs_data << {
      user_id: uid,
      phone_number: Faker::PhoneNumber.phone_number,
      call_start_time: Faker::Time.between(from: 1.year.ago, to: Time.now),
      call_end_time: Faker::Time.between(from: 1.year.ago, to: Time.now),
      duration: rand(60..1800),  # Duration in seconds (1 minute to 30 minutes)
      name: Faker::Name.name
    }
end

CallLog.insert_all(call_logs_data)

User.all.each do |u|
  first_name = u.email.split('@')[0]
  u.update(first_name: first_name)
end