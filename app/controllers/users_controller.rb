class UsersController < ApplicationController
    def index
        users = User.all
        render json: users
    end

    def show
        user = User.find_by(id: params[:id])
        render json: user
    end

    def create
        user = User.new(name: params[:name], age: params[:age])
        user.save
        render json: user
    end

    def update
        user = User.find_by(id: params[:id])
        user.name = params[:name]
        user.age = params[:age]
        user.save
        render json: user
    end

    def destroy
        user = User.find_by(id: params[:id])
        user.destroy
    end
end
