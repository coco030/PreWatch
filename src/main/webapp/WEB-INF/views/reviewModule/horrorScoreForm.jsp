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
<div class="rating-guide-wrap">
<div id="horrorScore-rating" class="d-flex align-items-center" style="font-size: 1.5rem;">
    <c:forEach begin="1" end="5" var="i">
        <span class="star-wrapper me-1" data-index="${i}">
            <span class="half left-half" data-value="${i * 2 - 1}"></span>
            <span class="half right-half" data-value="${i * 2}"></span>
            <span class="rating-icon rating-icon-empty" aria-hidden="true">★</span>
            <span class="rating-icon rating-icon-fill" aria-hidden="true">★</span>
        </span>
    </c:forEach>

    <!-- ⭐ 점수 라벨 표시 -->
    <div class="ms-2" id="score-label" style="font-size: 0.9rem; font-weight: 500;">
        <c:if test="${not empty myReview.horrorScore}">
            ${myReview.horrorScore} / 10
        </c:if>
    </div>
</div>
<div class="rating-guide-bubble" id="horror-guide" aria-live="polite"></div>
</div>

<!-- ⭐ 별점 관련 CSS - -->
<style>
    .rating-guide-wrap {
        position: relative;
        display: inline-block;
        max-width: 100%;
    }

    /* 별점 컨테이너 정렬 개선 */
    #horrorScore-rating {
        line-height: 1; /* 라인 높이를 1로 고정해서 수직 정렬 안정화 */
        height: auto;   /* 높이 자동 조정 */
    }

    .star-wrapper {
        position: relative;
        display: inline-block;
        width: 1.08em;
        height: 1.08em;
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

    #horrorScore-rating .rating-icon {
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

    #horrorScore-rating .rating-icon-empty {
        color: #ddd;
    }

    #horrorScore-rating .rating-icon-fill {
        color: #4682B4;
        width: 0;
        transition: width 0.12s ease;
    }

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

    #horror-guide.rating-guide-bubble {
        position: absolute;
        top: calc(100% + 6px);
        left: 0;
        z-index: 30;
        width: max-content;
        max-width: min(390px, calc(100vw - 32px));
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

    #horror-guide.rating-guide-bubble.is-visible {
        opacity: 1;
        visibility: visible;
        transform: translateY(0);
    }

    #horror-guide.rating-guide-bubble::before {
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
        #horrorScore-rating {
            font-size: 1rem;  /* 모바일에서는 더 작게 */
        }
        
        #score-label {
            font-size: 0.8rem;
        }

        #horror-guide.rating-guide-bubble {
            max-width: calc(100vw - 32px);
            font-size: 0.78rem;
        }
    }
</style>

<!-- ⭐ 공포 점수 별점 로직 (수정할 필요 없음) -->
<script>
document.addEventListener("DOMContentLoaded", function () {
    const movieId = document.getElementById("movieId")?.value;
    const contextPath = '${pageContext.request.contextPath}';
    const stars = document.querySelectorAll("#horrorScore-rating .half");
    const icons = document.querySelectorAll("#horrorScore-rating .rating-icon-fill");
    const label = document.getElementById("score-label");
    const guide = document.getElementById("horror-guide");
    const horrorGuideMessages = [
        { max: 1, text: "무섭거나 불안한 장면이 거의 없어요." },
        { max: 2, text: "무섭기보다 긴장감이 약한 수준이에요." },
        { max: 4, text: "어두운 분위기나 약한 놀람 요소가 있어요." },
        { max: 6, text: "긴장감, 불안감, 점프스케어가 있어요." },
        { max: 8, text: "심리적 압박이나 공포 장면이 강해요." },
        { max: 10, text: "보는 내내 불쾌감이나 공포감이 크게 남아요." }
    ];

    let currentScore = horrorScore;

    // 초기 렌더링
    if (currentScore > 0) {
        updateStars(currentScore);
        label.textContent = currentScore + " / 10";
    } else {
        label.textContent = "";
    }
    hideRatingGuide();

    // 마우스 오버
    stars.forEach(star => {
        star.addEventListener("mouseover", function () {
            const previewScore = parseInt(this.dataset.value);
            updateStars(previewScore);
            label.textContent = previewScore + " / 10";
            showRatingGuide(previewScore);
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
        hideRatingGuide();
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
            showRatingGuide(score);

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
            let width = "0%";
            if (score >= value) {
                width = "100%";
            } else if (score === value - 1) {
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
        const guideMessage = horrorGuideMessages.find(item => score <= item.max);
        return guideMessage ? guideMessage.text : "";
    }
});
</script>
