document.addEventListener("DOMContentLoaded", function () {
  const isLoggedIn = document.body.dataset.loggedIn === "true";
  const loginModalElement = document.getElementById("loginModal");
  const borrowModalElement = document.getElementById("borrowModal");

  const loginModal = loginModalElement ? new bootstrap.Modal(loginModalElement) : null;
  const borrowModal = borrowModalElement ? new bootstrap.Modal(borrowModalElement) : null;

  document.addEventListener("click", function (e) {
    const btn = e.target.closest(".add_to_favorite_button, .borrow_button, .write_a_review_button");
    if (!btn) return;

    if (!isLoggedIn && loginModal) {
      e.preventDefault();
      loginModal.show();
    } else {
      if (btn.classList.contains("borrow_button") && borrowModal) {
        borrowModal.show();
      }
    }
  });
});
