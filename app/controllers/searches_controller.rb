class SearchesController < ApplicationController
  def show
    query = params[:q].to_s.strip

    return render json: { error: "Query is required" }, status: :bad_request if query.blank?

    results = search_service.search(
      query,
      page_num: params[:page],
      no_cache: params[:no_cache] == "true"
    )

    render json: results
  end

  def clear_cache
    render json: search_service.clear_cache
  end

  private

  def search_service
    Rails.application.config.search_service
  end
end