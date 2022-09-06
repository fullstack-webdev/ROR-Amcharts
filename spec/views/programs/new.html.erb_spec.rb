require 'spec_helper'

describe "programs/new" do
  before(:each) do
    assign(:program, stub_model(Program).as_new_record)
  end

  it "renders new program form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => programs_path, :method => "post" do
    end
  end
end
