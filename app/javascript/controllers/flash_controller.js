import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    setTimeout(() => {
      const yOffset = -100; // cuộn thêm 100px lên trên
      const y = this.element.getBoundingClientRect().top + window.scrollY + yOffset;
      window.scrollTo({ top: y, behavior: 'smooth' });
    }, 50);

    // Tự fade out sau 5s
    setTimeout(() => {
      this.element.remove();
    }, 3000);
  }
}
