class Archive < ApplicationRecord
  belongs_to :version
  belongs_to :package
end
