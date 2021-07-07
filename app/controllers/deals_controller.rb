class DealsController < ApplicationController
  def index
    @pagy, @deals = pagy(Deal.with_files.order('created_at DESC'))
  end

  def show
    @deal = Deal.find(params[:id])
    @archives_scope = Archive.where(deal_id: @deal).includes(:version, :package)
    @pagy, @archives = pagy(@archives_scope)
  end
end
