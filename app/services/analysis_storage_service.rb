class AnalysisStorageService
  def self.store_results(collection, csv_response)
    # Remove the ```csv wrapper and parse
    clean_csv = csv_response.gsub(/^```csv\n/, '').gsub(/\n```$/, '')
    
    CSV.parse(clean_csv, headers: true, liberal_parsing: true) do |row|
      collection.analysis_results.create!(
        response_id: row['id'].to_i,
        text: row['text'],
        thematic_codes: row['thematic_codes'],
        sentiment: row['sentiment'],
        is_garbage: row['is_garbage'] == 'true'
      )
    end
    
    collection.analysis_results.count
  end
end