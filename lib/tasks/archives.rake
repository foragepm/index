namespace :archives do
  task record_recent: :environment do
    ids = Version.without_archives.order('versions.created_at DESC').limit(1000).pluck(:id)
    ids.each{|id| ArchiveVersionWorker.perform_async(id) }
  end
end
