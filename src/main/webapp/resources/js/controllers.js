
fetch("/review/rating?movieId=" + movieId)
  .then(res => res.text())
  .then(html => {
    document.getElementById("rating-box").innerHTML = html;
  });