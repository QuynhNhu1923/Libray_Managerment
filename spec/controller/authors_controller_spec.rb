require "rails_helper"

RSpec.describe Admin::AuthorsController, type: :controller do
  let(:admin) { create(:user, :admin) } # giả sử user có role admin
  let!(:author) { create(:author) }

  before do
    sign_in admin
  end

  describe "GET #index" do
    it "assigns authors and renders index" do
      get :index
      expect(assigns(:authors)).to include(author)
      expect(response).to render_template(:index)
    end
  end

  describe "GET #show" do
    it "renders show if author exists" do
      get :show, params: { id: author.id }
      expect(assigns(:author)).to eq(author)
      expect(response).to render_template(:show)
    end

    it "redirects if author not found" do
      get :show, params: { id: 0 }
      expect(response).to redirect_to(admin_authors_path)
      expect(flash[:alert]).to eq(I18n.t("admin.authors.flash.not_found"))
    end
  end

  describe "GET #new" do
    it "assigns a new author" do
      get :new
      expect(assigns(:author)).to be_a_new(Author)
      expect(response).to render_template(:new)
    end
  end

  describe "POST #create" do
    let(:valid_params) { { author: { name: "New Author" } } }
    let(:invalid_params) { { author: { name: "" } } }

    it "creates a new author with valid params" do
      expect {
        post :create, params: valid_params
      }.to change(Author, :count).by(1)
      expect(response).to redirect_to(admin_authors_path)
      expect(flash[:success]).to eq(I18n.t("admin.authors.flash.create.success"))
    end

    it "renders new with invalid params" do
      post :create, params: invalid_params
      expect(response).to render_template(:new)
      expect(flash[:alert]).to eq(I18n.t("admin.authors.flash.create.failure"))
    end
  end

  describe "GET #edit" do
    it "assigns the author for editing" do
      get :edit, params: { id: author.id }
      expect(assigns(:author)).to eq(author)
      expect(response).to render_template(:edit)
    end
  end

  describe "PATCH #update" do
    let(:update_params) { { author: { name: "Updated Name" } } }
    let(:invalid_update_params) { { author: { name: "" } } }

    it "updates author with valid params" do
      patch :update, params: { id: author.id }.merge(update_params)
      author.reload
      expect(author.name).to eq("Updated Name")
      expect(response).to redirect_to(admin_author_path(author))
      expect(flash[:success]).to eq(I18n.t("admin.authors.flash.update.success"))
    end

    it "renders edit with invalid params" do
      patch :update, params: { id: author.id }.merge(invalid_update_params)
      expect(response).to render_template(:edit)
      expect(flash[:alert]).to eq(I18n.t("admin.authors.flash.update.failure"))
    end
  end

  describe "DELETE #destroy" do
    it "destroys author successfully" do
      expect {
        delete :destroy, params: { id: author.id }
      }.to change(Author, :count).by(-1)
      expect(response).to redirect_to(admin_authors_path)
      expect(flash[:success]).to eq(I18n.t("admin.authors.flash.destroy.success"))
    end

    it "redirects if author not found" do
      delete :destroy, params: { id: 0 }
      expect(response).to redirect_to(admin_authors_path)
      expect(flash[:alert]).to eq(I18n.t("admin.authors.flash.not_found"))
    end
  end
end
