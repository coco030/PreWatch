<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<!-- jQuery CDN (AJAX 및 이벤트 핸들용) -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<!-- Font Awesome 아이콘 (별 모양 표시용) -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

<!-- ⭐ 서버에서 전달된 영화 ID를 숨겨서 전달 (후속 AJAX 요청에 필요) -->
<input type="hidden" id="movieId" value="${movieId}" />
<!-- 비로그인 상태일 때랑 구분해서 -->
<c:if test="${not empty loginMember}">
    <input type="hidden" id="isLoggedIn" value="true" />
</c:if>

<!-- ⭐ 초기 사용자 별점 정보: 문자열로 받지만 JS 숫자로 변환 -->
<script>
    const userRating = Number("${myReview.userRating}");
</script>

<!-- ⭐ 별점 표시 영역 - 크기 축소 및 정렬 개선 -->
<div id="star-rating" class="d-flex align-items-center" style="font-size: 1.8rem;">
    <c:forEach begin="1" end="5" var="i">
        <span class="star-wrapper me-1" data-index="${i}">
            <span class="half left-half" data-value="${i * 2 - 1}"></span>
            <span class="half right-half" data-value="${i * 2}"></span>
            <i class="fa-regular fa-star"></i>
        </span>
    </c:forEach>

    <!-- ⭐ 점수 라벨 표시 (평가 안했을 경우는 빈칸) -->
    <div class="ms-2" id="rating-label" style="font-size: 0.9rem; font-weight: 500;">
        <c:if test="${not empty myReview.userRating}">
            ${myReview.userRating} / 10
        </c:if>
    </div>
</div>

<!-- ⭐ 별점 관련 CSS - 크기 및 정렬 개선 -->
<style>
    /* 별점 컨테이너 정렬 개선 */
    #star-rating {
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

    /* 별 아이콘 스타일 - 크기 및 색상 개선 */
    .fa-regular.fa-star { 
        color: #ddd;           /* 빈 별 색상을 좀 더 연하게 */
        transition: color 0.2s ease; /* 색상 변화 애니메이션 */
    }
    
    .fa-solid.fa-star,
    .fa-solid.fa-star-half-stroke { 
        color: #ffc107;        /* 노란색을 좀 더 부드럽게 */
        transition: color 0.2s ease;
    }

    /* 호버 효과 제거 - 안정적인 UI 유지 */

    /* 점수 라벨 스타일 개선 */
    #rating-label {
        color: #666;           /* 텍스트 색상 */
        vertical-align: middle; /* 별과 수직 정렬 맞춤 */
        line-height: 1;        /* 라인 높이 통일 */
        margin-top: 1px;       /* 미세한 수직 정렬 보정 */
    }

    /* 반응형: 작은 화면에서 별점 크기 더 축소 */
    @media (max-width: 576px) {
        #star-rating {
            font-size: 1rem;  /* 모바일에서는 더 작게 */
        }
        
        #rating-label {
            font-size: 0.8rem;
        }
    }
</style>

<!-- ⭐ 별점 로직 (hover, click, AJAX 저장, 라벨 동기화) -->
<script>
document.addEventListener("DOMContentLoaded", function () {
    const movieId = document.getElementById("movieId")?.value;
    const contextPath = '${pageContext.request.contextPath}';
    const stars = document.querySelectorAll("#star-rating .half");
    const icons = document.querySelectorAll("#star-rating i");
    const label = document.getElementById("rating-label");

    let currentRating = userRating;

    // ⭐ 초기 렌더링
    if (currentRating > 0) {
        updateStars(currentRating);
        label.textContent = currentRating + " / 10";
    } else {
        label.textContent = "";
    }

    // ⭐ 마우스 오버 시: 프리뷰 렌더링
    stars.forEach(star => {
        star.addEventListener("mouseover", function () {
            const previewRating = parseInt(this.dataset.value);
            updateStars(previewRating);
            label.textContent = previewRating + " / 10";
        });
    });

    // ⭐ 마우스 아웃 시: 기존 점수 복원
    document.getElementById("star-rating").addEventListener("mouseleave", function () {
        updateStars(currentRating);
        if (currentRating > 0) {
            label.textContent = currentRating + " / 10";
        } else {
            label.textContent = "";
        }
    });

    // ⭐ 클릭 시: 평가 저장 및 UI 반영
    stars.forEach(star => {
        star.addEventListener("click", function () {
            // ⭐ 로그인 여부 확인
            const isLoggedIn = document.getElementById("isLoggedIn")?.value === "true";
            if (!isLoggedIn) {
                alert("로그인 후 이용 가능합니다.");
                return;
            }

            const rating = parseInt(this.dataset.value);
            currentRating = rating;

            updateStars(rating);
            label.textContent = rating + " / 10";

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
                console.log("저장 성공:", data);
            })
            .catch(err => {
                console.error("저장 실패:", err);
            });
        });
    });

    // ⭐ 별 아이콘 갱신 함수
    function updateStars(rating) {
        icons.forEach((icon, idx) => {
            const value = (idx + 1) * 2;

            icon.classList.remove("fa-solid", "fa-regular", "fa-star", "fa-star-half-stroke");

            if (rating >= value) {
                icon.classList.add("fa-solid", "fa-star");
            } else if (rating === value - 1) {
                icon.classList.add("fa-solid", "fa-star-half-stroke");
            } else {
                icon.classList.add("fa-regular", "fa-star");
            }
        });
    }
});
</script>