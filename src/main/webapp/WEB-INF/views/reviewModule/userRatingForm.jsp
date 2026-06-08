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
<div class="rating-guide-wrap">
<div id="star-rating" class="d-flex align-items-center" style="font-size: 1.5rem;">
    <c:forEach begin="1" end="5" var="i">
        <span class="star-wrapper me-1" data-index="${i}">
            <span class="half left-half" data-value="${i * 2 - 1}"></span>
            <span class="half right-half" data-value="${i * 2}"></span>
            <span class="rating-icon rating-icon-empty" aria-hidden="true">★</span>
            <span class="rating-icon rating-icon-fill" aria-hidden="true">★</span>
        </span>
    </c:forEach>

    <div class="ms-2" id="rating-label" style="font-size: 0.9rem; font-weight: 500;">
        <c:if test="${not empty myReview.userRating}">
            ${myReview.userRating} / 10
        </c:if>
    </div>
</div>
<div class="rating-guide-bubble" id="user-rating-guide" aria-live="polite"></div>
</div>

<style>
    #star-rating {
        line-height: 1; 
        height: auto;  
    }

    .rating-guide-wrap {
        position: relative;
        display: inline-block;
        max-width: 100%;
    }

    .star-wrapper {
        position: relative;
        display: inline-block;
        width: 1.08em;
        height: 1.08em;
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

    #star-rating .rating-icon {
        position: absolute;
        left: 0;
        top: 0;
        display: block;
        width: 100%;
        height: 100%;
        font-size: 1em;
        line-height: 1;
        overflow: hidden;
        pointer-events: none;
    }

    #star-rating .rating-icon-empty {
        color: #ddd;
    }

    #star-rating .rating-icon-fill {
        color: #ffc107;
        width: 0;
        transition: width 0.12s ease;
    }

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

    #user-rating-guide.rating-guide-bubble {
        position: absolute;
        top: calc(100% + 6px);
        left: 0;
        z-index: 30;
        width: max-content;
        max-width: min(360px, calc(100vw - 32px));
        box-sizing: border-box;
        padding: 7px 10px;
        border: 1px solid #dedede;
        border-radius: 6px;
        background: #fff;
        color: #444;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
        font-size: 0.82rem;
        line-height: 1.35;
        opacity: 0;
        visibility: hidden;
        pointer-events: none;
        transform: translateY(-2px);
        transition: opacity 0.12s ease, transform 0.12s ease;
    }

    #user-rating-guide.rating-guide-bubble.is-visible {
        opacity: 1;
        visibility: visible;
        transform: translateY(0);
    }

    #user-rating-guide.rating-guide-bubble::before {
        content: "";
        position: absolute;
        top: -6px;
        left: 18px;
        width: 10px;
        height: 10px;
        background: #fff;
        border-left: 1px solid #dedede;
        border-top: 1px solid #dedede;
        transform: rotate(45deg);
    }

    /* 반응형: 작은 화면에서 별점 크기 더 축소 */
    @media (max-width: 576px) {
        #star-rating {
            font-size: 1rem;  /* 모바일에서는 더 작게 */
        }
        
        #rating-label {
            font-size: 0.8rem;
        }

        #user-rating-guide.rating-guide-bubble {
            max-width: calc(100vw - 32px);
            font-size: 0.78rem;
        }
    }
</style>

<!-- ⭐ 별점 로직 (hover, click, AJAX 저장, 라벨 동기화) -->
<script>
document.addEventListener("DOMContentLoaded", function () {
    const movieId = document.getElementById("movieId")?.value;
    const contextPath = '${pageContext.request.contextPath}';
    const starRatingContainer = document.getElementById("star-rating");
    const stars = starRatingContainer.querySelectorAll(".half");
    const icons = starRatingContainer.querySelectorAll(".rating-icon-fill");
    const label = document.getElementById("rating-label");
    const guide = document.getElementById("user-rating-guide");
    const ratingGuideMessages = [
        { max: 1, text: "다신 보고 싶지 않아요." },
        { max: 2, text: "좋았던 점을 찾기 어려운 영화예요." },
        { max: 4, text: "아쉬운 점이 더 크게 남는 영화예요." },
        { max: 6, text: "무난하지만 강한 인상은 적은 편이에요." },
        { max: 8, text: "꽤 만족스럽고 추천할 만해요." },
        { max: 10, text: "취향에 잘 맞고 다시 보고 싶은 영화예요." }
    ];


    let currentRating = Number("${myReview.userRating}") || 0;


    function renderInitialRating() {
        updateStars(currentRating);
        if (currentRating > 0) {
            label.textContent = currentRating + " / 10";
        } else {
            label.textContent = "평가하기";
        }
        hideRatingGuide();
    }


    renderInitialRating();


    stars.forEach(star => {
        star.addEventListener("mouseover", function () {
            const previewRating = parseInt(this.dataset.value);
            updateStars(previewRating);
            label.textContent = previewRating + " / 10";
            showRatingGuide(previewRating);
        });
    });

    starRatingContainer.addEventListener("mouseleave", function () {
        renderInitialRating(); 
    });

    stars.forEach(star => {
        star.addEventListener("click", function () {
            const isLoggedIn = document.getElementById("isLoggedIn")?.value === "true";
            if (!isLoggedIn) {
                alert("로그인 후 이용 가능합니다.");
                renderInitialRating();
                return;
            }

            const newRating = parseInt(this.dataset.value);
            currentRating = newRating;

            updateStars(currentRating);
            label.textContent = currentRating + " / 10";
            showRatingGuide(currentRating);

            const formData = new URLSearchParams();
            formData.append("movieId", movieId);
            formData.append("userRating", currentRating);

            fetch(contextPath + "/review/saveRating", {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: formData
            })
            .then(res => {
                if (!res.ok) {
                    throw new Error('서버 응답 오류');
                }
                return res.json();
            })
            .then(data => {
                console.log("저장 성공:", data);
            })
            .catch(err => {
                console.error("저장 실패:", err);
                alert("별점 저장에 실패했습니다. 다시 시도해 주세요.");
            });
        });
    });

    function updateStars(rating) {
        icons.forEach((icon, idx) => {
            const starFullValue = (idx + 1) * 2;
            const starHalfValue = starFullValue - 1;
            let width = "0%";
            if (rating >= starFullValue) {
                width = "100%";
            } else if (rating === starHalfValue) {
                width = "50%";
            }
            icon.style.width = width;
        });
    }

    function showRatingGuide(score) {
        if (!guide) {
            return;
        }
        const message = getRatingGuideText(score);
        if (!message) {
            hideRatingGuide();
            return;
        }
        guide.textContent = message;
        guide.classList.add("is-visible");
    }

    function hideRatingGuide() {
        if (!guide) {
            return;
        }
        guide.textContent = "";
        guide.classList.remove("is-visible");
    }

    function getRatingGuideText(score) {
        const guideMessage = ratingGuideMessages.find(item => score <= item.max);
        return guideMessage ? guideMessage.text : "";
    }
});
</script>
