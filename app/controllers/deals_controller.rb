class DealsController < ApplicationController
  def index
    @pagy, @deals = pagy(Deal.aggregate.order('created_at DESC'))
  end

  def show
    @deal = Deal.find(params[:id])
    @archives_scope = Archive.where(deal_id: @deal).includes(:version, :package)
    @pagy, @archives = pagy_countless(@archives_scope)
  end
end
