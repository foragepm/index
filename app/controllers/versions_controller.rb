class VersionsController < ApplicationController
  def recent
    @scope = Version.includes(:package).order('published_at DESC, created_at DESC')
    @pagy, @versions = pagy_countless(@scope)
  end
end
