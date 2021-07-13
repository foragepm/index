class VersionsController < ApplicationController
  def recent
    @scope = Version.includes(:package).order('published_at DESC')
    @pagy, @versions = pagy(@scope)
  end
end
