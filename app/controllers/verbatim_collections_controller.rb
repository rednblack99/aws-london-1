class VerbatimCollectionsController < ApplicationController
  def show
    @collection = VerbatimCollection.find(params[:id])
  end

  def analyze
    @collection = VerbatimCollection.find(params[:id])
    
    analysis_service = AnalysisService.new
    @results = analysis_service.analyze_csv_data(@collection)
    
    render :results
  end
end