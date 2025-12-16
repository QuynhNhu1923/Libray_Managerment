function initStarRating(container) {
  const stars = container.querySelectorAll(".star");
  const ratingScore = container.querySelector("input[name='review[score]']");
  if (!stars.length || !ratingScore) return;

  let selectedRating = parseInt(ratingScore.value || "0", 10) || 0;

  const updateStars = (rating) => {
    stars.forEach((s) => {
      const v = parseInt(s.dataset.value, 10);
      s.classList.toggle("selected", v <= rating);
    });
  };

  updateStars(selectedRating);

  stars.forEach((star) => {
    const v = parseInt(star.dataset.value, 10);

    star.addEventListener("mouseover", () => updateStars(v));
    star.addEventListener("mouseout", () => updateStars(selectedRating));

    star.addEventListener("click", () => {
      selectedRating = v;
      ratingScore.value = v;
      updateStars(selectedRating);
    });
  });

  // Validate khi submit form
  const form = container.closest("form");
  if (form) {
    form.addEventListener("submit", (e) => {
      if (!ratingScore.value || parseInt(ratingScore.value, 10) < 1) {
        e.preventDefault();
        alert(I18n.t("books.review_form.missing_score"));
      }
    });
  }
}

document.addEventListener("turbo:load", () => {
  document.addEventListener("click", (e) => {
    const writeBtn = e.target.closest("#writeReviewBtn");
    if (!writeBtn) return;

    const formWrap = document.getElementById("reviewForm");
    const userPanel = document.getElementById("user_review");
    if (formWrap) {
      formWrap.classList.remove("d-none");
      if (userPanel) userPanel.classList.add("d-none");
      writeBtn.classList.add("d-none");

      const formEl = formWrap.querySelector("form");
      if (formEl) initStarRating(formEl);
    }
  });

  document.addEventListener("click", (e) => {
    const cancelBtn = e.target.closest("#cancelReviewBtn");
    if (!cancelBtn) return;

    const formWrap = document.getElementById("reviewForm");
    const userPanel = document.getElementById("user_review");
    const writeBtn = document.getElementById("writeReviewBtn");

    if (formWrap && writeBtn) {
      formWrap.classList.add("d-none");
      if (userPanel) userPanel.classList.remove("d-none");
      writeBtn.classList.remove("d-none");
    }
  });

  document.addEventListener("click", (e) => {
    const star = e.target.closest(".star");
    if (!star) return;

    const form = star.closest("form");
    const input = form?.querySelector("input[name='review[score]']");
    const value = parseInt(star.dataset.value, 10);
    if (input) {
      input.value = value;
      const stars = star.parentNode.querySelectorAll(".star");
      stars.forEach((s) => {
        const v = parseInt(s.dataset.value, 10);
        s.classList.toggle("selected", v <= value);
      });
    }
  });
});
