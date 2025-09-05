class AnalysisService
  def initialize
    @bedrock_service = BedrockService.new
  end

  def analyze_csv_data(csv_file_path)
    puts "Reading prompt file..."
    prompt = File.read(Rails.root.join('storage', 'prompt_1.md'))
    puts "Prompt loaded: #{prompt.length} characters"
    
    puts "Reading CSV data..."
    csv_data = File.read(csv_file_path)
    puts "CSV loaded: #{csv_data.length} characters"
    
    full_prompt = "#{prompt}\n\n## CSV Data to Analyze:\n```\n#{csv_data}\n```"
    puts "Combined prompt: #{full_prompt.length} characters"
    
    puts "Sending to Bedrock..."
    response = @bedrock_service.converse(full_prompt, max_tokens: 4000, temperature: 0.3)
    
    puts "Parsing CSV response..."
    results = @bedrock_service.parse_csv_response(response)
    puts "Parsed #{results.length} rows"
    results
  end
end