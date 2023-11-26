require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?

require "./models"
enable :sessions


helpers do
    def current_user
        User.find_by(id: session[:user])
    end
end

before "/tasks" do
    if current_user.nil?
        redirect "/"
    end
end

get "/" do
    # @lists = List.all
    # if current_user.nil?
    #     @tasks = Task.none
    # elsif params[:list].nil? then
    #     @tasks = current_user.tasks
    # else
    #     @tasks = List.find(params[:list]).tasks.where(user_id: current_user.id)
    # end
    # puts @tasks
    if session[:user].nil?
    redirect "/signin"
    else
    
    @courses = Course.all
    erb :index
    end
end

get "/signup" do
    erb :sign_up
end

post "/signup" do
    user = User.create(
        name: params[:name],
        password: params[:password],
        password_confirmation: params[:password_confirmation]
    )
    
    if user.persisted?
        session[:user] = user.id
    end
    redirect "/"
end

get "/signin" do
    erb :sign_in
end

post "/signin" do
    user = User.find_by(name: params[:name])

    if user && user.authenticate(params[:password])
        session[:user] = user.id
    end
    redirect "/"
end

post "/signout" do
    session[:user] = nil
    redirect "/"
end

get "/signout" do
    session[:user] = nil
    redirect "/"
end

post '/search' do
  # フォームから送信された検索クォリを取得
  search_query = params[:query]

  # 検索クォリに基づいてCourseテーブルを検索
  # カラム名に大文字が含まれている場合、ダブルクォートで囲む
  @courses = Course.where('"className" LIKE ?', "%#{search_query}%")

  # 検索結果を表示するためのERBファイルをレンダリング
  erb :results
end



# get "/results" do
#     erb :results
# end

get "/courses/new" do
    erb :new
end

post "/courses" do
  # フォームデータから正しく値を取得する
  className = params[:className]
  teacher = params[:teacher]
  grade = params[:grade]
  week = params[:week]
  time = params[:time]

  # Courseオブジェクトを作成して保存
  course = Course.create(
    className: className,
    teacher: teacher,
    grade: grade,
    week: week,
    time: time
  )

  if course.persisted?
    # コースが正常に保存された場合
    redirect "/"
  else
    # Courseの保存に失敗した場合の処理
    flash[:error] = "コースの保存に失敗しました。"
    redirect "/"
  end
end

get "/courses/:id" do
    @courseId = params[:id]
    @course = Course.find(params[:id])
    @reviews = Review.where(courseId: @courseId)
    erb :detail
end

# 口コミを追加するルート
post '/courses/:id/reviews' do
  course = Course.find(params[:id])
  course.reviews.create(params[:review])
#   @courseId = params[:courseId]
  redirect back
end

get '/courses/:id/reviews/new' do
    @courseId = params[:id]
  course = Course.find(params[:id])
  @courseName = course.className  # className 属性を @courseName に代入
    erb :review_form
end

post '/check_form' do
  # Store the form data in a hash
  @form_data = {
    quantity: params[:quantity],
    reference: params[:reference],
    groupWork: params[:groupWork],
    hasTests: params[:hasTests],
    hasReports: params[:hasReports],
    hasProgramming: params[:hasProgramming],
    targetAudience: params[:targetAudience],
    otherComments: params[:otherComments],
    rating: params[:rating],
    courseId: params[:courseId]
  }

  erb :check_form
end

post '/submit_form' do
    review = Review.create(
        dropRate: params[:quantity],
        workload: params[:reference] == 'true',
        groupWork: params[:groupWork] == 'true',
        hasTests: params[:hasTests] == 'true',
        hasReports: params[:hasReports] == 'true',
        hasProgramming: params[:hasProgramming] == 'true',
        targetAudience: params[:targetAudience],
        otherComments: params[:otherComments],
        likes: params[:rating],
        courseId: params[:courseId]  # コースIDを保存
      )
    
    redirect "/"
      
end
