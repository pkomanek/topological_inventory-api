require "manageiq-messaging"

RSpec.describe Api::V1x0::ServicePlansController, :type => :request do
  include ::Spec::Support::TenantIdentity
  let(:headers) { {"x-rh-identity" => identity} }

  it("Uses IndexMixin") { expect(described_class.instance_method(:index).owner).to eq(Api::V1::Mixins::IndexMixin) }
  it("Uses ShowMixin")  { expect(described_class.instance_method(:show).owner).to eq(Api::V1::Mixins::ShowMixin) }

  describe "#order" do
    let(:service_plan) do
      ServicePlan.create!(
        :source           => source,
        :tenant           => tenant,
        :service_offering => service_offering,
        :source_region    => source_region,
        :subscription     => subscription,
        :source_ref       => SecureRandom.uuid
      )
    end
    let(:source_region) { SourceRegion.create!(:tenant => tenant, :source => source, :source_ref => SecureRandom.uuid) }
    let(:source) { Source.create!(:tenant => tenant, :uid => SecureRandom.uuid) }
    let(:subscription) { Subscription.create!(:tenant => tenant, :source => source, :source_ref => SecureRandom.uuid) }
    let(:service_offering) do
      ServiceOffering.create!(
        :source        => source,
        :tenant        => tenant,
        :source_region => source_region,
        :subscription  => subscription,
        :source_ref    => SecureRandom.uuid
      )
    end

    let(:service_parameters) { {"DB_NAME" => "TEST_DB", "namespace" => "TEST_DB_NAMESPACE"} }
    let(:provider_control_parameters) { {"namespace" => "test_project", "OpenShift_param1" => "test"} }

    context "with a well formed service plan id" do
      let(:client) { double(:client) }
      let(:payload) do
        {
          "service_plan_id"             => service_plan.id.to_s,
          "service_parameters"          => service_parameters,
          "provider_control_parameters" => provider_control_parameters
        }
      end

      before do
        allow(ManageIQ::Messaging::Client).to receive(:open).and_return(client)
        allow(client).to receive(:publish_message)
      end

      it "publishes a message to the messaging client" do
        expect(client).to receive(:publish_message).with(
          :service => "platform.topological-inventory.operations-openshift",
          :message => "ServicePlan.order",
          :payload => {:request_context => headers, :params => {:task_id => kind_of(String), :service_plan_id => service_plan.id.to_s, :order_params => payload}}
        )

        post "/api/v1.0/service_plans/#{service_plan.id}/order", :params => payload, :headers => headers
      end

      it "returns json with the task id" do
        post "/api/v1.0/service_plans/#{service_plan.id}/order", :params => payload, :headers => headers

        @body = JSON.parse(response.body)
        expect(@body).to have_key("task_id")
      end
    end

    context "with a malicious service plan id" do
      it "returns an error" do
        post "/api/v1.0/service_plans/;myfakeSQLinjection/order", :headers => headers

        expect(response.status).to eq(400)
      end

      it "does not try to look the model up by the fake ID" do
        expect(ServicePlan).to_not receive(:find).with(";myfakeSQLinjection")

        post "/api/v1.0/service_plans/;myfakeSQLinjection/order", :headers => headers
      end
    end
  end
end