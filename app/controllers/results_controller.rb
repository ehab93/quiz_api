class ResultsController < ApplicationController
  before_action :set_result, only: [:show, :update, :destroy]

  # GET /users/:user_id/quizzes/:quiz_id/results
  # GET /results.json
  def index
    if User.find(params[:user_id]).role == "doc"
      @results = Result.where({user_id: params[:user_id],
        quiz_id: params[:quiz_id]}).first
    else
      @results = Result.where({user_id: params[:user_id],
        quiz_id: params[:quiz_id], published: true}).first
    end

    render json: @results
  end

  # GET /results/1
  # GET /results/1.json
  def show
    render json: @result
  end

  # POST /results
  # POST /results.json
  def create
    @result = Result.new(result_params)

    if @result.save
      render json: @result, status: :created, location: @result
    else
      render json: @result.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /results/1
  # PATCH/PUT /results/1.json
  def update
    @result = Result.find(params[:id])

    if @result.update(result_params)
      head :no_content
    else
      render json: @result.errors, status: :unprocessable_entity
    end
  end

  def update_results_status
    Result.where(quiz_id: params[:quiz_id]).each do |r|
      r.update(published: params[:result_status])
    end
  end

  # DELETE /results/1
  # DELETE /results/1.json
  def destroy
    @result.destroy

    head :no_content
  end

  private

    def set_result
      @result = Result.find(params[:id])
    end

    def result_params
      params.require(:result).permit(:result, :user_id, :quiz_id)
    end
end
