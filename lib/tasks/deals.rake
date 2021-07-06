namespace :deals do
  task sync: :environment do
    Deal.sync_deals
  end
end
