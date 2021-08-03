class HomeController < ApplicationController
  def index

  end

  def stats
    @without_archives = Version.where(yanked: false).without_archives.count
    @yanked = Version.where(yanked: true).count
    @not_pinned = Archive.not_pinned.count
    @not_pinned_web3 = Archive.where(web3: false).count
    @statuses = Archive.pinned.group(:pin_status).count
  end
end
