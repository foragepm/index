class VersionsController < ApplicationController
  def recent
    @scope = Version.includes(:package).order('id desc')#.order('published_at DESC NULLS LAST, created_at DESC')
    @pagy, @versions = pagy_countless(@scope)
  end
end
