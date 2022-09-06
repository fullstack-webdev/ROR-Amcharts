require 'spec_helper'

describe "drilling_strings/index" do
  before(:each) do
    assign(:drilling_strings, [
      stub_model(DrillingString),
      stub_model(DrillingString)
    ])
  end

  it "renders a list of drilling_strings" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
