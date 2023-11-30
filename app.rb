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
    if session[:user].nil?
    redirect "/signin"
    else
    
    user = User.find(session[:user])  # セッションからユーザー情報を取得
    @userName = user.name
    
    @courses = Course.all
    erb :index
    end
end

get "/signup" do
    @hide_navbar = true
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
    @hide_navbar = true
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
  # 検索フォームから送信されたデータをセッション変数に保存
  session[:search_query] = params[:general_search]
  session[:class_name] = params[:className]
  session[:teacher] = params[:teacher]
  session[:grade] = params[:grade]
  session[:week] = params[:week]
  session[:time] = params[:time]
  
  # フォームから送信された検索クエリを取得
  general_search = params[:general_search]
  class_name = params[:className]
  teacher = params[:teacher]
  grade = params[:grade]
  week = params[:week]
  time = params[:time]

  # データベース検索用のクエリを組み立てる
  query = Course.all
  query = query.where("\"className\" LIKE ?", "%#{general_search}%") unless general_search.to_s.strip.empty?
  query = query.where("\"className\" LIKE ?", "%#{class_name}%") unless class_name.to_s.strip.empty?
  query = query.where(teacher: teacher) unless teacher.to_s.strip.empty?
  query = query.where(grade: grade) unless grade.to_s.strip.empty?
  query = query.where(week: week) unless week.to_s.strip.empty?
  query = query.where(time: time) unless time.to_s.strip.empty?

  # 検索結果をインスタンス変数にセット
  @courses = query.to_a

  # 検索結果がない場合は検索ページにリダイレクトしてメッセージを表示
  if @courses.empty?
    session[:no_results] = true
    redirect '/search'
  else
    # 検索結果がある場合はそのまま結果を表示
    session[:no_results] = false
    erb :results
  end
  
end

get '/search' do
  # @courses が nil の場合は空の配列を設定
  @courses = [] if @courses.nil?
  
  user = User.find(session[:user])  # セッションからユーザー情報を取得
  @userName = user.name

  if session[:no_results]
    @message = '検索条件に当てはまるものが見つかりませんでした。'
    session[:no_results] = false # メッセージを表示した後はフラグをクリア
  end

  erb :results
end


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
    
  if @reviews.any?
    @average_rating = @reviews.average(:likes).round(1)
  else
    @average_rating = "No reviews yet"
  end

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
    user = User.find(session[:user])  # セッションからユーザー情報を取得

    review = Review.create(
        userName: user.name,  # ユーザー名を使用
        dropRate: params[:quantity],
        workload: params[:reference] == 'あり',
        groupWork: params[:groupWork] == 'あり',
        hasTests: params[:hasTests] == 'あり',
        hasReports: params[:hasReports] == 'あり',
        hasProgramming: params[:hasProgramming] == 'あり',
        targetAudience: params[:targetAudience],
        otherComments: params[:otherComments],
        likes: params[:rating],
        courseId: params[:courseId]  # コースIDを保存
      )
    
  redirect "/courses/#{params[:courseId]}"
      
end
