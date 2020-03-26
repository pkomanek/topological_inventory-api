require_relative "shared_examples_for_index"
require_relative "shared_examples_for_tags"

RSpec.describe("v3.0 - Security Group") do
  include ::Spec::Support::TenantIdentity

  let(:headers) { {"CONTENT_TYPE" => "application/json", "x-rh-identity" => identity} }
  let(:source) { Source.create!(:tenant => tenant) }

  let(:attributes) do
    {
      "source_id"  => source.id.to_s,
      "tenant_id"  => tenant.id.to_s,
      "source_ref" => SecureRandom.uuid
    }
  end

  include_examples(
    "v3x0_test_index_and_subcollections",
    "security_groups",
    [:vms]
  )

  include_examples("v3x0_test_tags_subcollection", "security_groups")
end
