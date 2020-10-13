class ChatsController < ApplicationController
  before_action :authenticate_user!

  # Loads:
  # @chats = all chats
  # @chat = current chat when applicable
  before_action :load_entities

  def index
    @chats = Chat.all
  end

  def new
    @chat = Chat.new
  end

  def create
    @chat = Chat.new permitted_parameters

    if @chat.save
      flash[:success] = "Chat #{@chat.name} was created successfully"
      redirect_to chats_path
    else
      render :new
    end
  end

  def edit
  end
  def show
  end

  def update
    if @chat.update_attributes(permitted_parameters)
      flash[:success] = "Chat #{@chat.name} was updated successfully"
      redirect_to chats_path
    else
      render :new
    end
  end

  def search  
    @chat = params[:id] if params[:id].present?
    query = params[:search][:query] if params[:search][:query]

    if query
      result = ChatMessage.search(query, @chat)
      @messages = result.records.joins(:user, :chat).select("chat_messages.*, chats.name as chatname, users.username")
    else
      @messages = nil
    end
    render :index
  end

  protected

  def load_entities
    @chats = Chat.all
    @chat = Chat.find(params[:id]) if params[:id]
  end

  def permitted_parameters
    params.require(:chat).permit(:name)
  end
end
