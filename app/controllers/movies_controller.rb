class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.ratings

    filters = get_ratings.presence || @all_ratings

    @movies = Movie.where(rating: filters)
    
    @hilite = nil

    session[:filter] = get_ratings
    
    if sort_by_title.present?
      session[:sort_by_title] = true
      session.delete(:sort_by_release_date)
      @movies = @movies.order(title: :asc)
      @hilite = "title"
    elsif sort_by_release_date.present?
      session[:sort_by_release_date] = true
      session.delete(:sort_by_title)
      @movies = @movies.order(release_date: :asc)
      @hilite = "release_date"
    end

    @movies
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private

  def sort_by_title
    params.fetch(:sort_by_title, false) || (!params.fetch(:sort_by_release_date, false) && session.fetch(:sort_by_title, false))
  end

  def sort_by_release_date
    params.fetch(:sort_by_release_date, false) || (!params.fetch(:sort_by_title, false) && session.fetch(:sort_by_release_date, false))
  end 

  def get_ratings
    params.fetch(:ratings, {}).keys.presence || session.fetch(:filter, [])
  end

end
