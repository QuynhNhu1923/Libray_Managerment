export function hideModal(selector) {
  const modalEl = document.querySelector(selector)
  if (modalEl) {
    const modal = bootstrap.Modal.getInstance(modalEl)
    if (modal) {
      modal.hide()
    }
  }
}
