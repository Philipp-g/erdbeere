class BuildingBlock < ApplicationRecord
  belongs_to :explained_structure, class_name: "Structure", foreign_key: "explained_structure_id"
  belongs_to :structure
  has_many :atoms, as: :stuff_w_props
end
