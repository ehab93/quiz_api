class AnswersController < ApplicationController
  before_action :set_answer, only: [:show, :update, :destroy]

  # GET /answers
  # GET /answers.json
  def index
    @answers = Answer.where(url_params)
    if @answers.size == 1
      @answers.first!
    end
    render json: @answers
  end

  # GET /answers/1
  # GET /answers/1.json
  def show
    render json: @answer
  end

  # POST /answers
  # POST /answers.json
  def create
    passed = true
    count = 0
    if params[:status] == "listOfAnswers"
      params[:answers].each do |ans|
        @answer = Answer.new(answers_params(ans))
        if @answer.save
          if @answer.correct
            count = count + 1
            # update_result ans[:user_id], ans[:quiz_id]
          end
        else
          passed = false
        end
      end
      if passed
        create_result params[:answers].first[:user_id], params[:answers].first[:quiz_id], count
        render json: @answer, status: :created, location: @answer
      else
        render json: @answer.errors, status: :unprocessable_entity
      end
    else
      @answer = Answer.new(answer_params)
      if @answer.save
        if @answer.correct
          update_result
        end
        render json: @answer, status: :created, location: @answer
      else
        render json: @answer.errors, status: :unprocessable_entity
      end
    end
  end

  # PATCH/PUT /answers/1
  # PATCH/PUT /answers/1.json
  def update
    @answer = Answer.find(params[:id])

    if @answer.update(answer_params)
      head :no_content
    else
      render json: @answer.errors, status: :unprocessable_entity
    end
  end

  # DELETE /answers/1
  # DELETE /answers/1.json
  def destroy
    @answer.destroy

    head :no_content
  end

  private

    def update_result user_id, quiz_id
      puts "**********#{quiz_id}"
      currnet_quiz = Quiz.find(quiz_id) 
      quiz_mark = currnet_quiz.quiz_mark
      question_no = currnet_quiz.questions.size
      if question_no != 0
        question_weight = quiz_mark / question_no
      else
        question_weight = 0
      end
      rslt = Result.where({user_id: user_id, quiz_id: quiz_id}).first

      old_rslt = rslt.result
      rslt.result = old_rslt + questions_weight
      rslt.save
    end

    def create_result user_id, quiz_id, count
      currnet_quiz = Quiz.find(quiz_id) 
      quiz_mark = currnet_quiz.quiz_mark
      question_no = currnet_quiz.questions.size
      if question_no != 0
        question_weight = quiz_mark / question_no
      else
        question_weight = 0
      end
      rslt = Result.new({result: (count*question_weight),
       user_id: user_id, quiz_id: quiz_id, published: false})
      rslt.save
    end

    def set_answer
      @answer = Answer.find(params[:id])
    end

    def answer_params
      { answer: myParam[:answer],
        correct: myParam[:answer] == (Question.find(myParam[:question_id]).right_answer)}.merge url_params
    end

    def answers_params myParam
      { answer: myParam[:answer],    
        correct: myParam[:answer] == (Question.find(myParam[:question_id]).right_answer),
        user_id: myParam[:user_id],
        quiz_id: myParam[:quiz_id],
        question_id: myParam[:question_id] }
    end

    def url_params
      h = {user_id: params[:user_id],
      quiz_id: params[:quiz_id]}
      if  params[:question_id]
        h.merge question_id: params[:question_id]
      end
    end
end
