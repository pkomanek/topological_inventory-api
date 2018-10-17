module Api
  module V0
    class SourcesController < ApplicationController
      def create
        body = JSON.parse(request.body.read)
        source = Source.create!(:tenant_id => body["tenant_id"], :name => body["name"])
        render :json => source, :status => :created, :location => api_v0x0_source_url(source.id)
      end

      def destroy
        Source.destroy(params[:id])
        head :no_content
      rescue ActiveRecord::RecordNotFound
        head :not_found
      end

      def index
        render json: Source.where(list_params)
      end

      def show
        render json: Source.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        head :not_found
      end

      def update
        Source.update(params[:id], :name => params[:name])
        head :no_content
      rescue ActiveRecord::RecordNotFound
        head :not_found
      end

      private

      def list_params
        params.permit(:tenant_id)
      end
    end
  end
end
