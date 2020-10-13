class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  if Rails.env == "test"
    connects_to database: { writing: :primary, reading: :primary }
  else
    connects_to database: { writing: :primary, reading: :primary_replica }
  end
end
