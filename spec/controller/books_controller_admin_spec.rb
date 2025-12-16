require "rails_helper"

RSpec.describe Admin::BooksController, type: :controller do
  let(:admin) { create(:user, :admin) } # giả sử bạn có factory admin
  let!(:author) { create(:author) }
  let!(:publisher) { create(:publisher) }
  let!(:book) { create(:book, author: author, publisher: publisher) }

  before do
    sign_in admin
  end

  describe "GET #index" do
    it "assigns @books and renders index" do
      get :index
      expect(assigns(:books)).to include(book)
      expect(response).to render_template(:index)
    end
  end

  describe "GET #show" do
    it "shows the book" do
      get :show, params: { id: book.id }
      expect(assigns(:book)).to eq(book)
      expect(response).to render_template(:show)
    end

    it "redirects if book not found" do
      get :show, params: { id: 0 }
      expect(response).to redirect_to(admin_books_path)
      expect(flash[:alert]).to eq(I18n.t("admin.books.flash.not_found"))
    end
  end

  describe "GET #new" do
    it "assigns a new book" do
      get :new
      expect(assigns(:book)).to be_a_new(Book)
      expect(response).to render_template(:new)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      let(:valid_params) do
        {
          title: "New Book",
          description: "Some description",
          publication_year: 2023,
          total_quantity: 5,
          available_quantity: 5,
          author_id: author.id,
          publisher_id: publisher.id
        }
      end

      it "creates a book and redirects" do
        expect do
          post :create, params: { book: valid_params }
        end.to change(Book, :count).by(1)
        expect(response).to redirect_to(admin_books_path)
        expect(flash[:success]).to eq(I18n.t("admin.books.flash.create.success"))
      end
    end

    context "with invalid params" do
      it "renders new with errors" do
        post :create, params: { book: { title: "" } }
        expect(response).to render_template(:new)
        expect(flash.now[:alert]).to eq(I18n.t("admin.books.flash.create.failure"))
      end
    end
  end

  describe "GET #edit" do
    it "assigns book for edit" do
      get :edit, params: { id: book.id }
      expect(assigns(:book)).to eq(book)
      expect(response).to render_template(:edit)
    end
  end

  describe "PATCH #update" do
    context "with valid params" do
      it "updates the book and redirects" do
        patch :update, params: { id: book.id, book: { title: "Updated Title" } }
        expect(book.reload.title).to eq("Updated Title")
        expect(response).to redirect_to(admin_book_path(book))
        expect(flash[:success]).to eq(I18n.t("admin.books.flash.update.success"))
      end
    end

    context "with invalid params" do
      it "renders edit with errors" do
        patch :update, params: { id: book.id, book: { title: "" } }
        expect(response).to render_template(:edit)
        expect(flash.now[:alert]).to eq(I18n.t("admin.books.flash.update.failure"))
      end
    end
  end

  describe "DELETE #destroy" do
    context "existing book" do
      it "destroys the book and redirects" do
        expect do
          delete :destroy, params: { id: book.id }
        end.to change(Book, :count).by(-1)
        expect(response).to redirect_to(admin_books_path)
        expect(flash[:success]).to eq(I18n.t("admin.books.flash.destroy.success"))
      end
    end

    context "nonexistent book" do
      it "redirects with not found" do
        delete :destroy, params: { id: 0 }
        expect(response).to redirect_to(admin_books_path)
        expect(flash[:alert]).to eq(I18n.t("admin.books.flash.not_found"))
      end
    end
  end
end
