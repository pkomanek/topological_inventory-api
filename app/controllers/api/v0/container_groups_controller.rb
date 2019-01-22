module Api
  module V0
    class ContainerGroupsController < ApplicationController
      include Api::V0::Mixins::IndexMixin
      include Api::V0::Mixins::ShowMixin

      private

      def list_params
        params.permit(:source_id, :tenant_id, :container_project_id, :container_node_id)
      end

      def model
        ContainerGroup
      end
    end
  end
end
