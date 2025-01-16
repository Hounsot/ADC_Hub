class VacanciesController < ApplicationController
  before_action :set_vacancy, only: %i[ show edit update destroy ]

  def index
    @vacancies = Vacancy.includes(:company).order(created_at: :desc)
  end

  def show
  end

  def new
    @vacancy = Vacancy.new
  end

  def create
    @vacancy = Vacancy.new(vacancy_params)
    @vacancy.user = current_user

    if @vacancy.save
      redirect_to @vacancy, notice: "Vacancy was successfully created."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @vacancy.update(vacancy_params)
      redirect_to @vacancy, notice: "Vacancy was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @vacancy.destroy
    redirect_to vacancies_url, notice: "Vacancy was successfully destroyed."
  end

  private

  def set_vacancy
    @vacancy = Vacancy.find(params[:id])
  end

  def vacancy_params
    params.require(:vacancy).permit(:title, :description, :salary, :location, :employment_type, :company_id)
  end
end
