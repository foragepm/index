namespace :archives do
  task record_recent: :environment do
    ids = Version.where(yanked: false).without_archives.limit(1000).pluck(:id)
    ids.each{|id| ArchiveVersionWorker.perform_async(id) }
  end

  task add_to_estuary: :environment do
    ids = Archive.not_pinned.limit(1000).pluck(:id)
    ids.each{|id| EstuaryArchiveWorker.perform_async(id) }
  end

  task check_pin_statuses: :environment do
    ids = Archive.pinned.where(pin_status: ['pinning', 'queued']).limit(1000).order('pinned_at ASC').pluck(:id)
    ids.each{|id| CheckPinStatusWorker.perform_async(id) }
  end
end
