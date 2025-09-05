class AnalysisResult < ApplicationRecord
  belongs_to :verbatim_collection

  def self.ransackable_attributes(auth_object = nil)
    ["is_garbage", "parent_theme", "response_id", "sentiment", "text", "thematic_codes"]
  end
end
