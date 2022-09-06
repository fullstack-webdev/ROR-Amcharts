require "spec_helper"

describe DrillingStringsController do
  describe "routing" do

    it "routes to #index" do
      get("/drilling_strings").should route_to("drilling_strings#index")
    end

    it "routes to #new" do
      get("/drilling_strings/new").should route_to("drilling_strings#new")
    end

    it "routes to #show" do
      get("/drilling_strings/1").should route_to("drilling_strings#show", :id => "1")
    end

    it "routes to #edit" do
      get("/drilling_strings/1/edit").should route_to("drilling_strings#edit", :id => "1")
    end

    it "routes to #create" do
      post("/drilling_strings").should route_to("drilling_strings#create")
    end

    it "routes to #update" do
      put("/drilling_strings/1").should route_to("drilling_strings#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/drilling_strings/1").should route_to("drilling_strings#destroy", :id => "1")
    end

  end
end
