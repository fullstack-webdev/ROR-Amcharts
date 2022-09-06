module Enum
  module EventWarningType
    SEVERITY = {
        options: [:low, :moderate, :high],
        default: :low
    }
    CATEGORY = {
        options: [:hole_cleaning, :wellbore_stability, :torque_drag, :gain_loss, :drilling_efficiency]
    }
  end
  module ActivityType
    CATEGORY = {
        options: [:hole_cleaning, :wellbore_stability, :torque_drag, :gain_loss, :drilling_efficiency]
    }
  end
end