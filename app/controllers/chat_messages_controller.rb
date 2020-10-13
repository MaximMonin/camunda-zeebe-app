class ChatMessagesController < ApplicationController
  before_action :authenticate_user!

  def show
    @chat = params[:id]
    @messages = ChatMessage.includes(:user).where(chat_id: @chat).order(created_at: :desc).references(:user).select('chat_messages.*, users.username, users.avatar' ).paginate(:per_page => 50, :page => params[:page])
    render json: @messages
  end

  def create
    @chat = Chat.find(params[:chat_id])
    @user = User.find(params[:user][:id])
    @message = ChatMessage.create user_id: @user[:id],
                                       chat_id: @chat[:id],
                                       message: params[:message],
                                       files: params[:files]
    ChatChannel.broadcast_to @chat, {message: @message, username: @user.username, avatar: @user.avatar} 
    render json: {}
  end
end
