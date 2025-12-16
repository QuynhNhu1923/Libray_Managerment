# spec/controllers/borrow_request_controller_spec.rb
require "rails_helper"

RSpec.describe BorrowRequestController, type: :controller do
  let(:user) { create(:user) }
  let(:book1) { create(:book, available_quantity: 5) }
  let(:book2) { create(:book, available_quantity: 2) }

  before do
    sign_in user
  end

  describe "GET #index" do
    it "loads cart items and paginates" do
      session[:borrow_cart] = [
        { "book_id" => book1.id, "quantity" => 1, "selected" => true },
        { "book_id" => book2.id, "quantity" => 2, "selected" => false }
      ]
      get :index
      expect(assigns(:cart_items).size).to eq(2)
      expect(assigns(:books_in_cart).keys).to include(book1.id, book2.id)
    end
  end

  describe "PATCH #update_borrow_cart" do
    before do
      session[:borrow_cart] = [
        { "book_id" => book1.id, "quantity" => 1, "selected" => false }
      ]
    end

    it "updates quantity and selected state" do
      patch :update_borrow_cart, params: {
        cart: { "0" => { quantity: 3, selected: BorrowRequestController::SELECTED } }
      }
      expect(session[:borrow_cart][0]["quantity"]).to eq(3)
      expect(session[:borrow_cart][0]["selected"]).to eq(true)
      expect(flash[:success]).to eq("Cart updated successfully.")
      expect(response).to redirect_to(borrow_request_index_path)
    end
  end

  describe "DELETE #remove_from_borrow_cart" do
    before do
      session[:borrow_cart] = [
        { "book_id" => book1.id, "quantity" => 1, "selected" => true }
      ]
    end

    it "removes book from cart" do
      delete :remove_from_borrow_cart, params: { book_id: book1.id }
      expect(session[:borrow_cart]).to be_empty
      expect(flash[:success]).to eq("Removed successfully")
      expect(response).to redirect_to(borrow_request_index_path)
    end

    it "returns JSON error if book not in cart" do
      delete :remove_from_borrow_cart, params: { book_id: 999 }, format: :json
      json = JSON.parse(response.body)
      expect(json["success"]).to eq(false)
      expect(json["message"]).to eq("Book is not in the borrow cart")
    end
  end

  describe "POST #checkout" do
    before do
      session[:borrow_cart] = [
        { "book_id" => book1.id, "quantity" => 2, "selected" => true }
      ]
      session[:start_date] = Date.tomorrow.to_s
      session[:end_date] = (Date.tomorrow + 1).to_s
    end

    it "creates borrow request and clears checked out books" do
      expect {
        post :checkout
      }.to change(BorrowRequest, :count).by(1)
      expect(session[:borrow_cart]).to be_empty
      expect(session[:start_date]).to be_nil
      expect(session[:end_date]).to be_nil
      expect(flash[:success]).to eq("Borrow request submitted successfully.")
      expect(response).to redirect_to(borrow_request_index_path)
    end

    it "redirects if no books selected" do
      session[:borrow_cart].each { |i| i["selected"] = false }
      post :checkout
      expect(flash[:danger]).to eq("Please select at least one book to borrow.")
      expect(response).to redirect_to(borrow_request_index_path)
    end

    it "redirects if not enough books in stock" do
      session[:borrow_cart][0]["quantity"] = book1.available_quantity + 1
      post :checkout
      expect(flash[:error].downcase).to include("insufficient")
      expect(response).to redirect_to(borrow_request_index_path)
    end
  end
end
