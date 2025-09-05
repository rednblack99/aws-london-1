require 'net/http'
require 'json'
require 'csv'

class BedrockService
  def initialize
    @region = ENV['AWS_REGION'] || 'us-east-1'
    @model_id = ENV['MODEL_ID'] || 'us.anthropic.claude-sonnet-4-20250514-v1:0'
    @bearer_token = ENV['AWS_BEARER_TOKEN_BEDROCK']
    puts "Token loaded: #{@bearer_token ? 'YES' : 'NO'}"
    puts "Token length: #{@bearer_token&.length || 0}"
  end

  def converse(text, max_tokens: 1000, temperature: 0.7, retries: 3)
    puts "Building request to Bedrock..."
    uri = URI("https://bedrock-runtime.#{@region}.amazonaws.com/model/#{@model_id}/converse")
    
    payload = {
      messages: [{
        role: 'user',
        content: [{ text: text }]
      }],
      inferenceConfig: {
        maxTokens: max_tokens,
        temperature: temperature
      }
    }
    puts "Payload size: #{payload.to_json.length} bytes"

    (retries + 1).times do |attempt|
      puts "Attempt #{attempt + 1}/#{retries + 1}"
      
      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, read_timeout: 120) do |http|
        request = Net::HTTP::Post.new(uri)
        request['Content-Type'] = 'application/json'
        request['Authorization'] = "Bearer #{@bearer_token}"
        request.body = payload.to_json
        http.request(request)
      end

      puts "Response: #{response.code}"
      
      if response.code == '200'
        result = JSON.parse(response.body)
        return result.dig('output', 'message', 'content', 0, 'text')
      elsif response.code == '429' && attempt < retries
        wait_time = 2 ** attempt
        puts "Rate limited. Waiting #{wait_time} seconds..."
        sleep(wait_time)
      else
        puts "Error: #{response.code} #{response.body}"
        return "Error: Unable to process request"
      end
    end
  rescue => e
    puts "Exception: #{e.class} - #{e.message}"
    "Error: Unable to process request"
  end

  def parse_csv_response(csv_text)
    puts "Attempting to parse CSV..."
    puts "CSV text length: #{csv_text.length}"
    puts "First 200 chars: #{csv_text[0..200]}"
    
    begin
      result = CSV.parse(csv_text, headers: true, liberal_parsing: true, quote_char: '"').map(&:to_h)
      puts "Standard parsing successful: #{result.length} rows"
      return result
    rescue CSV::MalformedCSVError => e
      puts "CSV parsing failed: #{e.message}"
      puts "Attempting manual parsing..."
      
      lines = csv_text.strip.split("\n")
      puts "Found #{lines.length} lines"
      
      return [] if lines.empty?
      
      headers = lines.first.split(",").map(&:strip)
      puts "Headers: #{headers}"
      
      results = []
      lines[1..-1].each_with_index do |line, index|
        next if line.strip.empty?
        
        # Simple split on comma, handling basic quotes
        fields = line.split(',').map { |f| f.strip.gsub(/^"(.*)"$/, '\\1') }
        
        if fields.length >= headers.length
          row_hash = {}
          headers.each_with_index do |header, i|
            row_hash[header] = fields[i] || ''
          end
          results << row_hash
        else
          puts "Skipping line #{index + 2}: field count mismatch (#{fields.length} vs #{headers.length})"
        end
      end
      
      puts "Manual parsing result: #{results.length} rows"
      results
    end
  end
end