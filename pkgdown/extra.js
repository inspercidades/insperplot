// Gallery sliders: arrow buttons scroll the track by about one slide
document.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll(".gallery-slider").forEach((slider) => {
    const track = slider.querySelector(".gallery-track");
    const step = () => track.clientWidth * 0.8;
    slider.querySelector(".gallery-prev").addEventListener("click", () => {
      track.scrollBy({ left: -step(), behavior: "smooth" });
    });
    slider.querySelector(".gallery-next").addEventListener("click", () => {
      track.scrollBy({ left: step(), behavior: "smooth" });
    });
  });
});
