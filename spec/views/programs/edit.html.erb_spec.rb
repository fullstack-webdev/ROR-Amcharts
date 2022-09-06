require 'spec_helper'

describe "programs/edit" do
  before(:each) do
    @program = assign(:program, stub_model(Program))
  end

  it "renders the edit program form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => programs_path(@program), :method => "post" do
    end
  end
end
