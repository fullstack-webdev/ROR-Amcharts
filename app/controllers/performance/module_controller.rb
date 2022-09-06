class Performance::ModuleController < ApplicationController
  before_filter :signed_in_user
  before_filter :color_palette
  set_tab :performance

  private

  def color_palette
    @color_palette = ["#58c9c2", "#b858c9", "#589dc9", "#9babee", "#23c9ff", "#9aea6a", "#9eddde", "#987cf4", "#23fcff"]
  end
end