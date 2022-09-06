require 'spec_helper'

describe "drilling_strings/edit" do
  before(:each) do
    @drilling_string = assign(:drilling_string, stub_model(DrillingString))
  end

  it "renders the edit drilling_string form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => drilling_strings_path(@drilling_string), :method => "post" do
    end
  end
end
