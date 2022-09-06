require 'spec_helper'

describe "drilling_strings/new" do
  before(:each) do
    assign(:drilling_string, stub_model(DrillingString).as_new_record)
  end

  it "renders new drilling_string form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => drilling_strings_path, :method => "post" do
    end
  end
end
