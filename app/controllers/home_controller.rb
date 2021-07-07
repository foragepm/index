class HomeController < ApplicationController
  def index

  end

  def stats
    @without_archives = Version.where(yanked: false).without_archives.count
    @yanked = Version.where(yanked: true).count
    @not_pinned = Archive.not_pinned.count
    @statuses = Archive.pinned.group(:pin_status).count
  end
end
