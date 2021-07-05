namespace :archives do
  task record_recent: :environment do
    ids = Version.without_archives.limit(3000).pluck(:id)
    ids.each{|id| ArchiveVersionWorker.perform_async(id) }
  end

  task add_to_estuary: :environment do
    ids = Archive.not_pinned.limit(2000).pluck(:id)
    ids.each{|id| EstuaryArchiveWorker.perform_async(id) }
  end

  task check_pin_statuses: :environment do
    ids = Archive.pinned.where(pin_status: nil).limit(2000).pluck(:id)
    ids.each{|id| CheckPinStatusWorker.perform_async(id) }
  end
end
