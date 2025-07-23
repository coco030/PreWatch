<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<!-- jQuery CDN (AJAX 및 이벤트 핸들용) -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<!-- Font Awesome 아이콘 (별 모양 표시용) -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

<!-- ⭐ 서버에서 전달된 영화 ID를 숨겨서 전달 (후속 AJAX 요청에 필요) -->
<input type="hidden" id="movieId" value="${movieId}" />

<!-- ⭐ 초기 사용자 별점 정보: 문자열로 받지만 JS 숫자로 변환 -->
<script>
    // JSTL로 렌더링된 점수 문자열을 JS 숫자로 변환 (예: "7" → 7)
    const userRating = Number("${myReview.userRating}");
</script>

<!-- ⭐ 별점 표시 영역 (1점 ~ 10점: 반개 단위로 5개의 아이콘 구성) -->
<div id="star-rating" style="font-size: 2rem;">
    <c:forEach begin="1" end="5" var="i">
        <span class="star-wrapper" data-index="${i}">
            <!-- 왼쪽 절반: 홀수 점수(1, 3, 5...) -->
            <span class="half left-half" data-value="${i * 2 - 1}"></span>
            <!-- 오른쪽 절반: 짝수 점수(2, 4, 6...) -->
            <span class="half right-half" data-value="${i * 2}"></span>
            <!-- 별 아이콘 (기본은 빈 별) -->
            <i class="fa-regular fa-star"></i>
        </span>
    </c:forEach>
</div>
<p>
  <strong>영화 만족도 : </strong>
  <c:choose>
    <c:when test="${not empty myReview.userRating}">
      ${myReview.userRating} / 10
    </c:when>
    <c:otherwise>
      <span style="color:gray;">아직 만족도 평가를 하지 않으셨어요.</span>
    </c:otherwise>
  </c:choose>
</p>

<!-- ⭐ 별점 관련 CSS (마우스 반응 및 별색 표현) -->
<style>
    .star-wrapper {
        position: relative;
        display: inline-block;
        cursor: pointer;
    }

    .star-wrapper .half {
        position: absolute;
        width: 50%;
        height: 100%;
        top: 0;
    }

    .left-half { left: 0; }
    .right-half { right: 0; }

    /* 기본 별색: 회색 */
    .fa-regular.fa-star { color: #ccc; }

    /* 채워진 별, 반 별: 노란색 */
    .fa-solid.fa-star,
    .fa-solid.fa-star-half-stroke { color: #f5b301; }
</style>

<!-- ⭐ 별점 클릭 처리 및 서버로 전송 -->
<script>
document.addEventListener("DOMContentLoaded", function () {
    const movieId = document.getElementById("movieId")?.value;
    const contextPath = '${pageContext.request.contextPath}'; // 앱 루트 경로
    const stars = document.querySelectorAll("#star-rating .half"); // 클릭 대상: 절반
    const icons = document.querySelectorAll("#star-rating i");     // 별 아이콘 전체

    // ⭐ 초기 렌더링: 서버에서 받은 userRating으로 별 채우기
    if (userRating > 0) {
        icons.forEach((icon, idx) => {
            const value = (idx + 1) * 2;
            if (userRating >= value) {
                icon.className = "fa-solid fa-star"; // 완전 별
            } else if (userRating === value - 1) {
                icon.className = "fa-solid fa-star-half-stroke"; // 반 별
            } else {
                icon.className = "fa-regular fa-star"; // 빈 별
            }
        });
    }

    // ⭐ 별 클릭 시: 점수 계산 + 서버 전송 + 즉시 별 다시 칠하기
    stars.forEach(star => {
        star.addEventListener("click", function () {
            const rating = parseInt(this.dataset.value); // 1~10 중 하나

            // 별 아이콘 채우기
            icons.forEach((icon, idx) => {
                const value = (idx + 1) * 2;
                if (rating >= value) {
                    icon.className = "fa-solid fa-star";
                } else if (rating === value - 1) {
                    icon.className = "fa-solid fa-star-half-stroke";
                } else {
                    icon.className = "fa-regular fa-star";
                }
            });

            // 서버로 AJAX POST 전송 (별점 저장)
            const formData = new URLSearchParams();
            formData.append("movieId", movieId);     // 영화 ID
            formData.append("userRating", rating);   // 클릭된 점수

            fetch(contextPath + "/review/saveRating", {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: formData
            })
            .then(res => res.json()) // JSON 파싱
            .then(data => {
                console.log("저장 성공:", data); // TODO: 사용자에게 알림 추가 가능
            })
            .catch(err => {
                console.error("저장 실패:", err); // TODO: 사용자에게 오류 알림 추가 가능
            });
        });
    });
});
</script>