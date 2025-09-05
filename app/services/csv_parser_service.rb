class CsvParserService
  def self.parse_and_store(file_path)
    lines = File.readlines(file_path).map(&:strip)
    
    project_title = lines[0]&.gsub(/^Project Title:\s*/, '')
    question_text = lines[1]&.gsub(/^"?Question text:\s*/, '')&.gsub(/"?\s*$/, '')
    
    collection = VerbatimCollection.create!(
      project_title: project_title,
      question_text: question_text
    )
    
    lines[2..-1].each do |line|
      next if line.empty?
      collection.verbatims.create!(text: line)
    end
    
    collection
  end
end