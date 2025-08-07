<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<input type="hidden" id="movieId" value="${movieId}" />
<c:if test="${not empty loginMember}">
    <input type="hidden" id="isLoggedIn" value="true" />
</c:if>
<script>
    const userRating = Number("${myReview.userRating}");
</script>
<div id="star-rating" class="d-flex align-items-center" style="font-size: 1.5rem;">
    <c:forEach begin="1" end="5" var="i">
        <span class="star-wrapper me-1" data-index="${i}">
            <span class="half left-half" data-value="${i * 2 - 1}"></span>
            <span class="half right-half" data-value="${i * 2}"></span>
            <i class="fa-regular fa-star"></i>
        </span>
    </c:forEach>

    <div class="ms-2" id="rating-label" style="font-size: 0.9rem; font-weight: 500;">
        <c:if test="${not empty myReview.userRating}">
            ${myReview.userRating} / 10
        </c:if>
    </div>
</div>

<style>
    #star-rating {
        line-height: 1; 
        height: auto;  
    }

    .star-wrapper {
        position: relative;
        display: inline-block;
        cursor: pointer;
        vertical-align: middle; 
        line-height: 1;     
    }

    .star-wrapper .half {
        position: absolute;
        width: 50%;
        height: 100%;
        top: 0;
        z-index: 10; 
    }

    .left-half { left: 0; }
    .right-half { right: 0; }

    /* 별 아이콘 스타일 - 크기 및 색상 개선 */
    .fa-regular.fa-star { 
        color: #ddd;  
        transition: color 0.2s ease;
    }
    
    .fa-solid.fa-star,
    .fa-solid.fa-star-half-stroke { 
        color: #ffc107;        /* 노란색을 좀 더 부드럽게 */
        transition: color 0.2s ease;
    }

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