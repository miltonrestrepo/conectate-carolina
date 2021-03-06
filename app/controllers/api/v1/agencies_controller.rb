class Api::V1::AgenciesController < ApplicationController
  def index
    agencies = Agency.all

    # when passed 'updated_since' parameter
    if params[:updated_since].present?
      updated_since = params[:updated_since]
      date = Time.parse(updated_since)
      agencies = agencies.where('updated_at >= ?', date)
    end

    # when passed `category_id` parameter
    if params[:category_id].present?
      category_id = params[:category_id]
      agencies = agencies.joins(:categories).where("categories.id" => category_id)
    end

    agencies = agencies.map do |agency|
      agency.new_agency_hash
    end

    render json: agencies, status: :ok
  end
end
