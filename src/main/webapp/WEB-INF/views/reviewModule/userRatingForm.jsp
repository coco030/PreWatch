<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!-- jQuery (필수) -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<!-- 별점 플러그인 -->
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/j-rating-advance.css">
<script src="${pageContext.request.contextPath}/resources/js/j-rating-advance.js"></script>

<!-- 숨겨진 영화 ID -->
<input type="hidden" id="movieId" value="${movie.id}" />

<!-- FontAwesome CDN 필요 -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

<!-- 별점 표시 영역 -->
<div id="star-rating" class="text-warning" style="font-size: 2rem;">
    <i class="fa-regular fa-star" data-value="1"></i>
    <i class="fa-regular fa-star" data-value="2"></i>
    <i class="fa-regular fa-star" data-value="3"></i>
    <i class="fa-regular fa-star" data-value="4"></i>
    <i class="fa-regular fa-star" data-value="5"></i>
</div>

<input type="hidden" id="movieId" value="${movie.id}" />

<script>
document.addEventListener("DOMContentLoaded", function () {
    const movieId = document.getElementById("movieId")?.value;
    const contextPath = '${pageContext.request.contextPath}';

    const stars = document.querySelectorAll("#star-rating i");

    stars.forEach((star, idx) => {
        star.addEventListener("click", function () {
            const clickedValue = parseInt(this.dataset.value);
            const rating = clickedValue * 2;  // 1~5 → 2~10점

            // ⭐ 별 하이라이트 처리
            stars.forEach((s, i) => {
                if (i < clickedValue) {
                    s.classList.remove("fa-regular");
                    s.classList.add("fa-solid");
                } else {
                    s.classList.remove("fa-solid");
                    s.classList.add("fa-regular");
                }
            });

            // ⭐ 서버로 AJAX 전송
            const formData = new URLSearchParams();
            formData.append("movieId", movieId);
            formData.append("userRating", rating);

            fetch(contextPath + "/review/saveRating", {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: formData
            })
            .then(res => res.json())
            .then(data => {
                console.log("별점 저장 성공:", data);
            })
            .catch(err => {
                console.error("별점 저장 실패:", err);
            });
        });
    });
});
</script>
