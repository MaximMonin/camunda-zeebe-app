class ConfirmationsController < Devise::ConfirmationsController
  def show
    ActiveRecord::Base.connected_to(role: :writing) do
      super
    end
  end
end 