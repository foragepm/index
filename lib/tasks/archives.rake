namespace :archives do
  task record_recent: :environment do
    ids = Version.without_archives.limit(2000).pluck(:id)
    ids.each{|id| ArchiveVersionWorker.perform_async(id) }
  end

  task add_to_estuary: :environment do
    ids = Archive.not_pinned.limit(2000).pluck(:id)
    ids.each{|id| EstuaryArchiveWorker.perform_async(id) }
  end

  task check_pin_statuses: :environment do
    Archive.pinned.where(pin_status: 'pinning').each(&:check_pin_status)
    ids = Archive.pinned.where(pin_status: 'queued').limit(2000).order('updated_at ASC').pluck(:id)
    ids.each{|id| CheckPinStatusWorker.perform_async(id) }
  end
end
