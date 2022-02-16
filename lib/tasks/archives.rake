namespace :archives do
  task record_recent: :environment do
    ids = Version.where(yanked: false).without_archives.limit(1000).pluck(:id)
    ids.each{|id| ArchiveVersionWorker.perform_async(id) }
  end

  task add_to_estuary: :environment do
    ids = Archive.not_yanked.not_pinned.limit(500).pluck(:id)
    ids.each{|id| EstuaryArchiveWorker.perform_async(id) }
  end

  task add_to_web3_storage: :environment do
    Archive.not_yanked.where(web3: false).where(size: nil).limit(500).pluck(:id).each{|id| Web3StorageWorker.perform_async(id); sleep 1 };nil
  end

  task check_pin_statuses: :environment do
    Archive.check_pin_status
    ids = Archive.pinned.where(pin_status: ['pinning']).order('pinned_at ASC').pluck(:id)
    ids.each{|id| CheckPinStatusWorker.perform_async(id) };nil
  end

  task retry_failed_pins: :environment do
    Archive.retry_failed_pins
  end

  task update_counts: :environment do
    Archive.update_size_cache
    Archive.update_pinned_cache
    Version.update_total_cache
    Package.update_total_cache
  end
end
