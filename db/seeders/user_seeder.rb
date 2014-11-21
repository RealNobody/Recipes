class UserSeeder
  def self.seed
    puts("Seeding Users...")
    User.where(email: "realnobody1@cox.net").first_or_initialize().tap do |admin_user|
      admin_user.password = "password"
      admin_user.name     = "Real Nobody"
      admin_user.save!()
    end

    User.where(email: "guest@guest.com").first_or_initialize().tap do |admin_user|
      admin_user.password = "password"
      admin_user.name     = "guest@guest.com"
      admin_user.save!()
    end
  end
end