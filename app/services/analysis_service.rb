class AnalysisService
  def initialize
    @bedrock_service = BedrockService.new
  end

  def analyze_csv_data(collection)
    puts "Reading prompt file..."
    prompt = File.read(Rails.root.join('storage', 'prompt_1.md'))
    puts "Prompt loaded: #{prompt.length} characters"

    puts "Building CSV from collection data..."
    csv_content = [collection.project_title, collection.question_text]
    csv_content += collection.verbatims.pluck(:text)
    csv_data = csv_content.join("\n")
    puts "CSV built: #{csv_data.length} characters"

    full_prompt = "#{prompt}\n\n## CSV Data to Analyze:\n```\n#{csv_data}\n```"
    puts "Combined prompt: #{full_prompt.length} characters"

    puts "Sending to Bedrock..."
    response = @bedrock_service.converse(full_prompt, max_tokens: 4000, temperature: 0.3)

    # Save raw response to file
    timestamp = Time.current.to_i
    response_file = Rails.root.join('storage', 'responses', "#{timestamp}_bedrock_response.txt")
    FileUtils.mkdir_p(File.dirname(response_file))
    File.write(response_file, response)
    puts "Raw response saved to: #{response_file}"

    puts "Storing results in database..."
    count = AnalysisStorageService.store_results(collection, response)
    puts "Stored #{count} analysis results"

    collection.analysis_results
  end
end
