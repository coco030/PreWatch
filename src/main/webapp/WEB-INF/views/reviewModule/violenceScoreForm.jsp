<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<!-- jQuery CDN (AJAX 및 이벤트 핸들용) -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<!-- Font Awesome 아이콘 (원 모양 표시용) -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

<!-- ⭐ 서버에서 전달된 영화 ID -->
<input type="hidden" id="movieId" value="${movieId}" />

<!-- ⭐ 초기 사용자 폭력성 점수 정보 -->
<script>
    const violenceScore = Number("${myReview.violenceScore}");
</script>

<!-- ⭐ 폭력성 점수 표시 영역 (1점 ~ 10점: 반개 단위, 원 모양) -->
<div id="violence-score-rating" class="d-flex align-items-center" style="font-size: 2rem;">
    <c:forEach begin="1" end="5" var="i">
        <span class="circle-wrapper me-1" data-index="${i}">
            <span class="half left-half" data-value="${i * 2 - 1}"></span>
            <span class="half right-half" data-value="${i * 2}"></span>
            <i class="fa-regular fa-circle"></i>
        </span>
    </c:forEach>

    <div class="ms-2" style="font-size: 1rem;">
        <c:choose>
            <c:when test="${not empty myReview.violenceScore}">
                ${myReview.violenceScore} / 10
            </c:when>
            <c:otherwise>
                <span style="color:gray;">아직 폭력성 평가를 하지 않으셨어요.</span>
            </c:otherwise>
        </c:choose>
    </div>
</div>


<!-- ⭐ 원 아이콘 관련 CSS -->
<style>
    .circle-wrapper {
        position: relative;
        display: inline-block;
        cursor: pointer;
    }

    .circle-wrapper .half {
        position: absolute;
        width: 50%;
        height: 100%;
        top: 0;
    }

    .left-half { left: 0; }
    .right-half { right: 0; }

    .fa-regular.fa-circle { color: #ccc; }

    .fa-solid.fa-circle,
    .fa-solid.fa-circle-half-stroke { color: #e54b4b; } /* 빨간색 원 */
</style>

<!-- ⭐ 폭력성 점수 클릭 및 AJAX 저장 -->
<script>
document.addEventListener("DOMContentLoaded", function () {
    const movieId = document.getElementById("movieId")?.value;
    const contextPath = '${pageContext.request.contextPath}';
    const halves = document.querySelectorAll("#violence-score-rating .half");
    const icons = document.querySelectorAll("#violence-score-rating i");

    if (violenceScore > 0) {
        icons.forEach((icon, idx) => {
            const value = (idx + 1) * 2;
            if (violenceScore >= value) {
                icon.className = "fa-solid fa-circle";
            } else if (violenceScore === value - 1) {
                icon.className = "fa-solid fa-circle-half-stroke";
            } else {
                icon.className = "fa-regular fa-circle";
            }
        });
    }

    halves.forEach(half => {
        half.addEventListener("click", function () {
            const score = parseInt(this.dataset.value);

            icons.forEach((icon, idx) => {
                const value = (idx + 1) * 2;
                if (score >= value) {
                    icon.className = "fa-solid fa-circle";
                } else if (score === value - 1) {
                    icon.className = "fa-solid fa-circle-half-stroke";
                } else {
                    icon.className = "fa-regular fa-circle";
                }
            });

            const formData = new URLSearchParams();
            formData.append("movieId", movieId);
            formData.append("violenceScore", score);

            fetch(contextPath + "/review/saveViolence", {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: formData
            })
            .then(res => res.json())
            .then(data => {
                console.log("폭력성 점수 저장 성공:", data);
            })
            .catch(err => {
                console.error("폭력성 점수 저장 실패:", err);
            });
        });
    });
});
</script>
