class UploadsController < ApplicationController
  def new
  end

  def create
    uploaded_file = params[:csv_file]
    
    if uploaded_file && uploaded_file.content_type == 'text/csv'
      filename = "#{Time.current.to_i}_#{uploaded_file.original_filename}"
      file_path = Rails.root.join('storage', 'uploads', filename)
      
      FileUtils.mkdir_p(File.dirname(file_path))
      File.open(file_path, 'wb') { |file| file.write(uploaded_file.read) }
      
      analysis_service = AnalysisService.new
      @results = analysis_service.analyze_csv_data(file_path)
      
      render :results
    else
      redirect_to new_upload_path, alert: "Please select a valid CSV file"
    end
  end
end