<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<!-- jQuery CDN (AJAX 및 이벤트 핸들용) -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<!-- Font Awesome 아이콘 (별 모양 표시용) -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

<!-- ⭐ 서버에서 전달된 영화 ID, 공포 점수 -->
<input type="hidden" id="movieId" value="${movieId}" />
<c:if test="${not empty loginMember}">
    <input type="hidden" id="isLoggedIn" value="true" />
</c:if>

<script>
const horrorScore = Number("${myReview.horrorScore}");
</script>

<!-- ⭐ 별점 표시 영역  "font-size: 1.5rem;" 별크기-->
<div id="horrorScore-rating" class="d-flex align-items-center" style="font-size: 1.5rem;">
    <c:forEach begin="1" end="5" var="i">
        <span class="star-wrapper me-1" data-index="${i}">
            <span class="half left-half" data-value="${i * 2 - 1}"></span>
            <span class="half right-half" data-value="${i * 2}"></span>
            <i class="fa-regular fa-star"></i>
        </span>
    </c:forEach>

    <!-- ⭐ 점수 라벨 표시 -->
    <div class="ms-2" id="score-label" style="font-size: 0.9rem; font-weight: 500;">
        <c:if test="${not empty myReview.horrorScore}">
            ${myReview.horrorScore} / 10
        </c:if>
    </div>
</div>

<!-- ⭐ 별점 관련 CSS - -->
<style>
    /* 별점 컨테이너 정렬 개선 */
    #horrorScore-rating {
        line-height: 1; /* 라인 높이를 1로 고정해서 수직 정렬 안정화 */
        height: auto;   /* 높이 자동 조정 */
    }

    .star-wrapper {
        position: relative;
        display: inline-block;
        cursor: pointer;
        vertical-align: middle; /* 수직 정렬을 중간으로 맞춤 */
        line-height: 1;         /* 별 아이콘의 라인 높이도 1로 고정 */
    }

    /* 반쪽 클릭 영역 설정 */
    .star-wrapper .half {
        position: absolute;
        width: 50%;
        height: 100%;
        top: 0;
        z-index: 10; /* 클릭 영역이 아이콘 위에 오도록 */
    }

    .left-half { left: 0; }
    .right-half { right: 0; }

    /* 빈 별 아이콘 스타일 */
    .fa-regular.fa-star { 
        color: #ddd;
        transition: color 0.2s ease; /* 색상 변화 애니메이션 */
    }
   
    #horrorScore-rating .fa-solid.fa-star,
    #horrorScore-rating .fa-solid.fa-star-half-stroke { 
        color: #4682B4; /* 공포 점수 고유의 파란색 유지 */
        transition: color 0.2s ease; 
    }

    #score-label {
        color: #666;           /* 텍스트 색상 */
        vertical-align: middle; /* 별과 수직 정렬 맞춤 */
        line-height: 1;        /* 라인 높이 통일 */
        margin-top: 1px;       /* 미세한 수직 정렬 보정 */
    }

    /* 반응형: 작은 화면에서 별점 크기 더 축소 */
    @media (max-width: 576px) {
        #horrorScore-rating {
            font-size: 1rem;  /* 모바일에서는 더 작게 */
        }
        
        #score-label {
            font-size: 0.8rem;
        }
    }
</style>

<!-- ⭐ 공포 점수 별점 로직 (수정할 필요 없음) -->
<script>
document.addEventListener("DOMContentLoaded", function () {
    const movieId = document.getElementById("movieId")?.value;
    const contextPath = '${pageContext.request.contextPath}';
    const stars = document.querySelectorAll("#horrorScore-rating .half");
    const icons = document.querySelectorAll("#horrorScore-rating i");
    const label = document.getElementById("score-label");

    let currentScore = horrorScore;

    // 초기 렌더링
    if (currentScore > 0) {
        updateStars(currentScore);
        label.textContent = currentScore + " / 10";
    } else {
        label.textContent = "";
    }

    // 마우스 오버
    stars.forEach(star => {
        star.addEventListener("mouseover", function () {
            const previewScore = parseInt(this.dataset.value);
            updateStars(previewScore);
            label.textContent = previewScore + " / 10";
        });
    });

    // 마우스 아웃
    document.getElementById("horrorScore-rating").addEventListener("mouseleave", function () {
        updateStars(currentScore);
        if (currentScore > 0) {
            label.textContent = currentScore + " / 10";
        } else {
            label.textContent = "";
        }
    });

    // 클릭 시 저장
    stars.forEach(star => {
        star.addEventListener("click", function () {
            const isLoggedIn = document.getElementById("isLoggedIn")?.value === "true";
            if (!isLoggedIn) {
                alert("로그인 후 이용 가능합니다.");
                return;
            }

            const score = parseInt(this.dataset.value);
            currentScore = score;

            updateStars(score);
            label.textContent = score + " / 10";

            const formData = new URLSearchParams();
            formData.append("movieId", movieId);
            formData.append("horrorScore", score);

            fetch(contextPath + "/review/saveHorrorUserScore", {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: formData
            })
            .then(res => res.json())
            .then(data => {
                console.log("공포 점수 저장 응답:", data);
            })
            .catch(err => {
                console.error("공포 점수 저장 중 오류:", err);
            });
        });
    });

    // 별 아이콘 렌더링 함수
    function updateStars(score) {
        icons.forEach((icon, idx) => {
            const value = (idx + 1) * 2;
            icon.classList.remove("fa-solid", "fa-regular", "fa-star", "fa-star-half-stroke");

            if (score >= value) {
                icon.classList.add("fa-solid", "fa-star");
            } else if (score === value - 1) {
                icon.classList.add("fa-solid", "fa-star-half-stroke");
            } else {
                icon.classList.add("fa-regular", "fa-star");
            }
        });
    }
});
</script>
