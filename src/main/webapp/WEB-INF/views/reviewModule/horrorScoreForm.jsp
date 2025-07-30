<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<!-- jQuery CDN (AJAX 및 이벤트 핸들용) -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<!-- Font Awesome 아이콘 (별 모양 표시용) -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

<!-- ⭐ 서버에서 전달된 영화 ID, 공포 점수 -->
<input type="hidden" id="movieId" value="${movieId}" />
<script>
const horrorScore = Number("${myReview.horrorScore}");
</script>


<!-- ⭐ 별점 표시 영역 -->
<div id="horrorScore-rating" class="d-flex align-items-center" style="font-size: 2rem;">
    <c:forEach begin="1" end="5" var="i">
        <span class="star-wrapper me-1" data-index="${i}">
            <span class="half left-half" data-value="${i * 2 - 1}"></span>
            <span class="half right-half" data-value="${i * 2}"></span>
            <i class="fa-regular fa-star"></i>
        </span>
    </c:forEach>

    <!-- 공포 점수 텍스트 -->
    <div class="ms-2" id="score-label" style="font-size: 1rem;">
        <c:choose>
            <c:when test="${not empty myReview.horrorScore}">
                ${myReview.horrorScore} / 10
            </c:when>
            <c:otherwise>
                <span style="color:gray;">아직 공포지수 평가를 하지 않으셨어요.</span>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<!-- ⭐ 별점 관련 CSS -->
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

    .fa-regular.fa-star { color: #ccc; }
    .fa-solid.fa-star,
    .fa-solid.fa-star-half-stroke { color: #f5b301; }
</style>

<!-- ⭐ 별점 클릭 및 AJAX 전송 -->
<script>
document.addEventListener("DOMContentLoaded", function () {
    const movieId = document.getElementById("movieId")?.value;
    const contextPath = '${pageContext.request.contextPath}';
    const stars = document.querySelectorAll("#horrorScore-rating .half");
    const icons = document.querySelectorAll("#horrorScore-rating i");
    const scoreLabel = document.getElementById("score-label");

    // ⭐ 초기 별 렌더링
    if (horrorScore > 0) {
        icons.forEach((icon, idx) => {
            const value = (idx + 1) * 2;
            if (horrorScore >= value) {
                icon.className = "fa-solid fa-star";
            } else if (horrorScore === value - 1) {
                icon.className = "fa-solid fa-star-half-stroke";
            } else {
                icon.className = "fa-regular fa-star";
            }
        });
    }

    // ⭐ 별 클릭
    stars.forEach(star => {
        star.addEventListener("click", function () {
            const rating = parseInt(this.dataset.value);

            // 별 다시 채우기
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

            // 텍스트도 업데이트
            scoreLabel.innerHTML = `${rating} / 10`;

            // AJAX 요청
            const formData = new URLSearchParams();
            formData.append("movieId", movieId);
            formData.append("horrorScore", rating);

            fetch(contextPath + "/review/saveHorrorUserScore", {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: formData
            })
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    console.log("저장 성공:", data);
                } else {
                    alert("공포평가 저장에 실패했습니다: " + data.message);
                }
            })
            .catch(err => {
                console.error("저장 실패:", err);
                alert("서버 오류로 저장에 실패했습니다.");
            });
        });
    });
});
</script>