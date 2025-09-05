class VerbatimCollection < ApplicationRecord
  has_many :verbatims, dependent: :destroy
  has_many :analysis_results, dependent: :destroy
end
