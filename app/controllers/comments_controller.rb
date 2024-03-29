class CommentsController < ApplicationController
  before_action :set_comment, only: %i[ show edit update destroy like ]
  before_action :authenticate_user!, except: %i[index show]
  before_action :correct_user, only: [:edit, :update, :destroy]
  respond_to :js, :html, :json

  def correct_user
    if user_signed_in? && @comment.user_id == current_user.id or current_user.try(:admin?)
    else
      redirect_to @question, notice: ">غير مصرح لك "
    end
  end

  def like
    if current_user.voted_for? @comment
      @comment.unliked_by current_user
    else
      @comment.liked_by current_user
    end
    redirect_back fallback_location: @question
    end

  # GET /comments or /comments.json
  def index
    @comments = Comment.all
  end

  # GET /comments/1 or /comments/1.json
  def show
  end

  # GET /comments/new
  def new
    @comment = Comment.new
  end

  # GET /comments/1/edit
  def edit
  end

  # POST /comments or /comments.json
  def create
    @question=Question.find(params[:question_id])
    @comment = @question.comments.new(comment_params.merge(user_id: current_user.id,))

    respond_to do |format|
      if @comment.save
        format.html { redirect_to @question, notice: "تم نشر التعليق بنجاح" }
        format.json { render :show, status: :created, location: @comment }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /comments/1 or /comments/1.json
  def update
    @question = Question.find_by_id @comment.question_id

    respond_to do |format|
      if @comment.update(comment_params)
        format.html { redirect_to @question, notice: "تم تعديل التعليق بنجاح" }
        format.json { render :show, status: :ok, location: @comment }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1 or /comments/1.json
  def destroy
    @question = Question.find_by_id @comment.question_id
    @comment.destroy
    respond_to do |format|
      format.html { redirect_to @question, notice: "تم حذف التعليق بنجاح" }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_comment
      @comment = Comment.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def comment_params
      params.require(:comment).permit(:body, :question_id, :user_id)
    end
end
