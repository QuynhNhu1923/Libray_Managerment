class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest

    if user.admin?
      # Admin có toàn quyền
      can :manage, :all
    elsif user.persisted? # logged-in normal user
      # Quyền đọc chung
      can :read, Book
      can :read, Author
      can :read, :favorites
      can :read, :follows
      can :read, BorrowRequest, user_id: user.id
      can :read, User, id: user.id

      # Quyền sửa profile của chính mình
      can :update, User, id: user.id

      # Quyền thao tác với BorrowRequest của chính mình
      can [:cancel, :edit_request, :update_request], BorrowRequest, user_id: user.id

      # Quyền thao tác với Book
      can :borrow, Book
      can [:add_to_favorite, :remove_from_favorite], Book
      can [:write_a_review, :destroy_review], Book

      # Quyền thao tác với Author
      can [:add_to_favorite, :remove_from_favorite], Author
    else
      # Guest
      can :read, Book
      can :read, Author
      # Cho phép đọc các trang public (symbol dùng cho controller/action)
      can :read, :home
      can :read, :about
      can :read, :search
    end
  end
end
