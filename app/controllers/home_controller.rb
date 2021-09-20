class HomeController < ApplicationController
  def index

  end

  def stats
    @without_archives = Version.where(yanked: false).without_archives.count
    @not_pinned = Archive.not_yanked.not_pinned.count
    @not_pinned_web3 = Archive.not_yanked.where(web3: false).count
    @statuses = Archive.pinned.not_yanked.where.not(pin_status: 'pinned').group(:pin_status).count
  end
end
