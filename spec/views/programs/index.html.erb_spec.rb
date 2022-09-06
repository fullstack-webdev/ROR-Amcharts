require 'spec_helper'

describe "programs/index" do
  before(:each) do
    assign(:programs, [
      stub_model(Program),
      stub_model(Program)
    ])
  end

  it "renders a list of programs" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
