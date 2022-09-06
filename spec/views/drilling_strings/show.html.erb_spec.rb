require 'spec_helper'

describe "drilling_strings/show" do
  before(:each) do
    @drilling_string = assign(:drilling_string, stub_model(DrillingString))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
