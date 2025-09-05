class VerbatimCollectionsController < ApplicationController
  def show
    @collection = VerbatimCollection.find(params[:id])
    if @collection.analysis_results.any?
      @q = @collection.analysis_results.ransack(params[:q])
      @filtered_results = @q.result.order(:response_id)
    end
  end

  def analyze
    @collection = VerbatimCollection.find(params[:id])
    
    analysis_service = AnalysisService.new
    @results = analysis_service.analyze_csv_data(@collection)
    
    render :results
  end
end