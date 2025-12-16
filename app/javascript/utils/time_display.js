function getCurrentLocale() {
  return document.body.dataset.locale || 'en-US';
}

function updateTime() {
  const now = new Date();

  const timeOptions = {
    hour: '2-digit',
    minute: '2-digit',
    hour12: true
  };

  const dateOptions = {
    weekday: 'short',
    day: '2-digit',
    month: '2-digit',
    year: 'numeric'
  };

  const timeElement = document.getElementById('current-hour');
  const dateElement = document.getElementById('current-date');

  const locale = getCurrentLocale(); // ✅ đọc mỗi lần update

  if (timeElement && dateElement) {
    try {
      timeElement.textContent = now.toLocaleTimeString(locale, timeOptions);
      dateElement.textContent = now.toLocaleDateString(locale, dateOptions);
    } catch (error) {
      console.error("Lỗi định dạng thời gian:", error);
    }
  }
}

document.addEventListener('turbo:load', () => {
  updateTime();
  setInterval(updateTime, 60000);
});
