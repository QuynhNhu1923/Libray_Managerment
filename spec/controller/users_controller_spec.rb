# spec/controllers/admin/users_controller_spec.rb
require "rails_helper"

RSpec.describe Admin::UsersController, type: :controller do
  let(:admin_user) { create(:user, :admin) }
  let(:user) { create(:user) }

  before do
    sign_in admin_user
    # Stub current_ability để CanCanCan không raise exception
    ability = Object.new
    ability.extend(CanCan::Ability)
    ability.can :manage, User
    allow(controller).to receive(:current_ability).and_return(ability)
  end

  describe "GET #index" do
    it "assigns @users and renders index" do
      get :index
      expect(assigns(:users)).to include(user)
      expect(response).to render_template(:index)
    end
  end

  describe "GET #show" do
    context "when user exists" do
      it "assigns @user and @borrow_requests" do
        borrow_request = create(:borrow_request, user: user)
        get :show, params: { id: user.id }
        expect(assigns(:user)).to eq(user)
        expect(assigns(:borrow_requests)).to include(borrow_request)
        expect(response).to render_template(:show)
      end
    end

    context "when user not found" do
        it "raises ActiveRecord::RecordNotFound" do
            expect { get :show, params: { id: 0 } }
            .to raise_error(ActiveRecord::RecordNotFound)
        end
    end

  end

  describe "PATCH #toggle_status" do
    context "when user is active" do
      it "sets user to inactive and shows notice" do
        user.active!
        patch :toggle_status, params: { id: user.id }
        user.reload
        expect(user).to be_inactive
        expect(flash[:notice]).to eq(I18n.t("admin.users.toggle_status.update_success"))
        expect(response).to redirect_to(admin_users_path)
      end
    end

    context "when user is inactive" do
      it "sets user to active and shows notice" do
        user.inactive!
        patch :toggle_status, params: { id: user.id }
        user.reload
        expect(user).to be_active
        expect(flash[:notice]).to eq(I18n.t("admin.users.toggle_status.update_success"))
        expect(response).to redirect_to(admin_users_path)
      end
    end

    context "when user not found" do
        it "raises ActiveRecord::RecordNotFound for show" do
            expect { get :show, params: { id: 0 } }
            .to raise_error(ActiveRecord::RecordNotFound)
        end

        it "raises ActiveRecord::RecordNotFound for toggle_status" do
            expect { patch :toggle_status, params: { id: 0 } }
            .to raise_error(ActiveRecord::RecordNotFound)
        end
        end


  end
end
