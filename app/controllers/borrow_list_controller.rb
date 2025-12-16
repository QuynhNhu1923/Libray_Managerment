class BorrowListController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource class: "BorrowRequest"
  before_action :set_borrow_request,
                only: %i(show cancel edit_request update_request)
  before_action :ensure_pending_request, only: :cancel

  rescue_from Pagy::OverflowError, with: :redirect_to_last_page
  rescue_from ActiveRecord::RecordNotFound, with: :redirect_not_found

  # GET /borrow_list
  def index
    @status = params[:status]
    @request_date_from = params[:request_date_from]
    @request_date_to   = params[:request_date_to]

    requests = current_user.borrow_requests
                           .includes(:user)
                           .by_status(@status)
                           .by_request_date_from(@request_date_from)
                           .by_request_date_to(@request_date_to)

    @pagy, @borrow_requests = pagy(
      requests.order(created_at: :desc),
      items: Settings.digits.digit_10
    )
  end

  # GET /borrow_list/:id
  def show
    @pagy, @borrowed_items = pagy(
      @borrow_request.borrow_request_items.includes(:book).order(:id),
      items: Settings.digits.digit_5
    )
  end

  # GET /borrow_list/:id/edit_request
  def edit_request
    @borrow_request.borrow_request_items.includes(:book)
  end

  # PATCH /borrow_list/:id/update_request
  def update_request
    # @borrow_request = BorrowRequest.find_(params[:id])
    # new_items = params[:borrow_request_items]
    # insufficient_books = check_book_availability(new_items)
    # if insufficient_books.any?
    #   flash.now[:danger] = t(".insufficient_books", books: insufficient_books.join(", "))
    #   render :edit_request, status: :unprocessable_entity
    #   return
    # end
    if @borrow_request.update(borrow_request_params.merge(status: :pending))
      flash[:success] = t(".update_success")
      redirect_to borrow_list_index_path
    else
      flash.now[:danger] = t(".update_failure")
      render :edit_request, status: :unprocessable_entity
    end
  end

  # PATCH /borrow_list/:id/cancel
  def cancel
    if @borrow_request.update(status: :cancelled)
      flash[:success] = t(".success")
    else
      flash[:danger] = t(".update_failed")
    end
    redirect_to borrow_list_index_path
  end

  private

  # def check_book_availability(borrow_request)
  #   insufficient_books = []

  #   borrow_request.borrow_request_items.each do |item|
  #     book = item.book
  #     if item.quantity > book.available_quantity
  #       insufficient_books << "#{book.title} (#{book.available_quantity} còn lại)"
  #     end
  #   end

  #   insufficient_books
  # end

  def borrow_request_params
    params.require(:borrow_request).permit(
      borrow_request_items_attributes: %i(id quantity _destroy)
    )
  end

  def ensure_pending_request
    return if @borrow_request&.pending?

    flash[:alert] = t(".failure")
    redirect_to borrow_list_index_path
  end

  def set_borrow_request
    @borrow_request =
      case action_name.to_sym
      when :show
        BorrowRequest.includes(borrow_request_items: :book)
                     .find_by(id: params[:id])
      when :cancel
        current_user.borrow_requests.find_by(id: params[:id])
      else
        current_user.borrow_requests.find_by(id: params[:id])
      end

    redirect_not_found unless @borrow_request
  end

  def redirect_not_found
    flash[:danger] = t(".not_found")
    redirect_to borrow_list_index_path
  end

  def redirect_to_last_page
    flash[:warning] = t(".page_not_found")
    # redirect_to request.path
    redirect_to url_for(page: @pagy&.last || 1)
  end
end
