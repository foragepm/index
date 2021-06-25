module Releases
  def stable_releases
    versions.select(&:stable?)
  end

  def prereleases
    versions.select(&:prerelease?)
  end

  def latest_stable_version
    @latest_version ||= stable_releases.sort.first
  end

  def latest_stable_release
    latest_stable_version
  end

  def latest_stable_release_number
    latest_stable_release.try(:number)
  end

  def latest_version
    versions.sort.first
  end

  def latest_release
    latest_version
  end

  def first_version
    @first_version ||= versions.sort.last
  end

  def first_release
    first_version
  end

  def latest_release_published_at
    read_attribute(:latest_release_published_at) || (latest_release.try(:published_at).presence || updated_at)
  end

  def set_latest_release_published_at
    self.latest_release_published_at = (latest_release.try(:published_at).presence || updated_at)
  end

  def set_latest_release_number
    self.latest_release_number = latest_release.try(:number)
  end

  def set_latest_stable_release_info
    latest_stable = latest_stable_release
    self.latest_stable_release_number = latest_stable.try(:number)
    self.latest_stable_release_published_at = (latest_stable.try(:published_at).presence || latest_stable.try([:updated_at]))
  end

  def set_runtime_dependencies_count
    self.runtime_dependencies_count = latest_release.try(:runtime_dependencies_count)
  end
end
