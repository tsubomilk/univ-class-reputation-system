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
    @lists = List.all
    if current_user.nil?
        @tasks = Task.none
    elsif params[:list].nil? then
        @tasks = current_user.tasks
    else
        @tasks = List.find(params[:list]).tasks.where(user_id: current_user.id)
    end
    # puts @tasks
    erb :index
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
    user = User.find_by(name :params[:name])
    if user && user.authenticate(params[:password])
        session[:user] = user.id
    end
    redirect "/"
end

get "/signout" do
    session[:user] = nil
    redirect "/"
end

get "/tasks/new" do
    erb :new
end

post "/tasks" do
    list = List.find(params[:list])
    current_user.tasks.create(
        title: params[:title],
        due_date: Date.parse(params[:due_date]),
        list_id: list.id
    )
    redirect "/"
end

post "/tasks/:id/done" do
    task = Task.find(params[:id])
    task.completed = true
    task.save
    redirect "/"
end

get "/tasks/:id/star" do
    task = Task.find(params[:id])
    task.star = !task.star
    task.save
    redirect "/"
end

post "/tasks/:id/delete" do
    task = Task.find(params[:id])
    task.destroy
    redirect "/"
end

get "/tasks/:id/edit" do
    @task=Task.find(params[:id])
    erb :edit
end

post "/tasks/:id" do
    task = Task.find(params[:id])
    date = params[:due_date].split("-")
    lsit = List.find(params[:list])
    
    if Date.valid_date?(date[0].to_i,date[1].to_i,date[2].to_i)
        task.title = params[:title]
        task.due_date = Date.parse(params[:due_date])
        task.list_id = list.id
        task.save
        redirect "/"
    else
        redirect "/tasks/#{task.id}/edit"
    end
end

get "/tasks/over" do
    @lists = List.all
    @tasks = current_user.tasks.where("due_date < ?",Date.today).where(completed: [nil,false])
    erb :index
end

get "/tasks/done" do
    @lists = List.all
    @tasks = current_user.tasks.where(completed: true)
    erb :index
end

