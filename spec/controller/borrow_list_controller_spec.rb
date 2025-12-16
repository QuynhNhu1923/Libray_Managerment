require "rails_helper"

RSpec.describe BorrowListController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:user) { create(:user) }
  let(:book) { create(:book, available_quantity: 5) }
  let!(:borrow_request) { create(:borrow_request, user: user) }
  let!(:borrow_item) { create(:borrow_request_item, borrow_request: borrow_request, book: book, quantity: 2) }

  before do
    sign_in user
  end

  describe "GET #index" do
    it "returns http success and assigns borrow requests" do
      get :index
      expect(response).to have_http_status(:ok)
      expect(assigns(:borrow_requests)).to include(borrow_request)
      expect(assigns(:pagy)).to be_present
    end

    it "filters by status" do
      get :index, params: { status: borrow_request.status }
      expect(assigns(:borrow_requests)).to include(borrow_request)
    end
  end

  describe "GET #show" do
    it "returns http success and assigns borrowed_items" do
      get :show, params: { id: borrow_request.id }
      expect(response).to have_http_status(:ok)
      expect(assigns(:borrowed_items)).to include(borrow_item)
      expect(assigns(:pagy)).to be_present
    end

    it "redirects if borrow request not found" do
      nonexistent_id = BorrowRequest.maximum(:id).to_i + 1

      get :show, params: { id: nonexistent_id }

      expect(response).to redirect_to(borrow_list_index_path)
      expect(flash[:danger]).to eq(I18n.t("borrow_list.not_found"))
    end
  end

  describe "GET #edit_request" do
    it "assigns borrow_request_items" do
      get :edit_request, params: { id: borrow_request.id }
      expect(assigns(:borrow_request).borrow_request_items).to include(borrow_item)
    end
  end

  describe "PATCH #update_request" do
    context "with valid params" do
      it "updates borrow request and redirects" do
        patch :update_request, params: { id: borrow_request.id, borrow_request: { borrow_request_items_attributes: [{ id: borrow_item.id, quantity: 3 }] } }
        expect(borrow_item.reload.quantity).to eq(3)
        expect(flash[:success]).to eq(I18n.t("borrow_list.update_request.update_success"))
        expect(response).to redirect_to(borrow_list_index_path)
      end
    end

    context "with invalid params" do
      it "renders edit_request with error" do
        allow_any_instance_of(BorrowRequest).to receive(:update).and_return(false)
        patch :update_request, params: { id: borrow_request.id, borrow_request: { borrow_request_items_attributes: [{ id: borrow_item.id, quantity: 10 }] } }
        expect(flash.now[:danger]).to eq(I18n.t("borrow_list.update_request.update_failure"))
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(:edit_request)
      end
    end
  end

  describe "PATCH #cancel" do
    context "when request is pending" do
      it "cancels the borrow request and redirects" do
        borrow_request.update(status: :pending)
        patch :cancel, params: { id: borrow_request.id }
        expect(borrow_request.reload.status).to eq("cancelled")
        expect(flash[:success]).to eq(I18n.t("borrow_list.success"))
        expect(response).to redirect_to(borrow_list_index_path)
      end
    end

    context "when request is not pending" do
      it "does not cancel and shows alert" do
        borrow_request.update(status: :approved)
        patch :cancel, params: { id: borrow_request.id }
        expect(flash[:alert]).to eq(I18n.t("borrow_list.failure"))
        expect(response).to redirect_to(borrow_list_index_path)
      end
    end
  end
end
