require 'spec_helper'

describe "DrillingStrings" do
  describe "GET /drilling_strings" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get drilling_strings_path
      response.status.should be(200)
    end
  end
end
