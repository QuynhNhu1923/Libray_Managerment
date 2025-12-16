require "rails_helper"

RSpec.describe BooksController, type: :controller do
  let(:user) { create(:user) }
  let(:book) { create(:book) }

  before do
    sign_in user
  end

  describe "GET #show" do
    it "renders html successfully" do
      get :show, params: { id: book.id }
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:show)
      expect(assigns(:book)).to eq(book)
    end

    it "renders turbo_stream successfully" do
      get :show, params: { id: book.id }, format: :turbo_stream
      expect(response.content_type).to start_with("text/vnd.turbo-stream.html")
    end

    it "redirects if book not found" do
      get :show, params: { id: 0 }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(I18n.t("books.show.book_not_found"))
    end
  end

  describe "GET #search" do
    it "returns books with query" do
      get :search, params: { q: book.title, search_type: "title" }
      expect(response).to render_template(:search)
      expect(assigns(:books)).to include(book)
    end

    it "returns books without query" do
      get :search
      expect(response).to render_template(:search)
      expect(assigns(:books)).to include(book)
    end
  end

  describe "POST #add_to_favorite" do
    it "adds a favorite successfully" do
      post :add_to_favorite, params: { id: book.id }
      expect(user.favorites.where(favorable: book)).to exist
      expect(response).to redirect_to(book)
      expect(flash[:notice]).to eq(I18n.t("books.show.favorite_success"))
    end
  end

  describe "DELETE #remove_from_favorite" do
    let!(:favorite) { create(:favorite, user: user, favorable: book) }

    it "removes a favorite successfully" do
      delete :remove_from_favorite, params: { id: book.id }
      expect(user.favorites.where(favorable: book)).not_to exist
      expect(response).to redirect_to(book)
      expect(flash[:notice]).to eq(I18n.t("books.show.unfavorite_success"))
    end
  end

  describe "POST #write_a_review" do
    let(:review_params) { { score: 5, comment: "Great book!" } }

    it "creates a review successfully" do
      post :write_a_review, params: { id: book.id, review: review_params }
      expect(user.reviews.where(book: book, score: 5)).to exist
      expect(response).to redirect_to(book)
    end

    it "renders show on validation error" do
      post :write_a_review, params: { id: book.id, review: { score: nil } }
      expect(response).to render_template(:show)
    end
  end

  describe "POST #borrow" do
    it "adds book to session borrow_cart" do
      post :borrow, params: { id: book.id, quantity: 2 }

      # kiểm tra session
      expect(session[:borrow_cart]).to include(hash_including("book_id" => book.id, "quantity" => 2))

      # kiểm tra redirect
      expect(response).to redirect_to(a_string_including(book_path(book)))

      # kiểm tra flash
      expect(flash[:notice]).to eq(I18n.t("books.flash.added_to_borrow_cart"))
    end
  end


  describe "DELETE #destroy_review" do
    let!(:review) { create(:review, user: user, book: book) }

    it "deletes the user's review" do
      delete :destroy_review, params: { id: book.id }

      expect(user.reviews.where(book: book)).not_to exist
      expect(response).to redirect_to(book_path(book))
      expect(flash[:notice]).to eq(I18n.t("books.destroy_review.deleted"))
    end
  end
end
