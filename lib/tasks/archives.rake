namespace :archives do
  task record_recent: :environment do
    ids = Version.without_archives.limit(3000).pluck(:id)
    ids.each{|id| ArchiveVersionWorker.perform_async(id) }
  end

  task add_to_estuary: :environment do
    ids = Archive.where(pin_id: nil).limit(2000).pluck(:id)
    ids.each{|id| EstuaryArchiveWorker.perform_async(id) }
  end
end
