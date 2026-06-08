<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

<input type="hidden" id="movieId" value="${movieId}" />
<c:if test="${not empty loginMember}">
    <input type="hidden" id="isLoggedIn" value="true" />
</c:if>

<!-- 폭력성 점수 정보 -->
<script>
    const violenceScore = Number("${myReview.violenceScore}");
</script>

<div class="rating-guide-wrap">
<div id="violence-score-rating" class="d-flex align-items-center" style="font-size: 1.5rem;">
    <c:forEach begin="1" end="5" var="i">
        <span class="circle-wrapper me-1" data-index="${i}">
            <span class="half left-half" data-value="${i * 2 - 1}"></span>
            <span class="half right-half" data-value="${i * 2}"></span>
            <span class="rating-icon rating-icon-empty" aria-hidden="true">●</span>
            <span class="rating-icon rating-icon-fill" aria-hidden="true">●</span>
        </span>
    </c:forEach>

    <div class="ms-2" id="violence-label" style="font-size: 0.9rem;">
        <c:if test="${not empty myReview.violenceScore}">
            ${myReview.violenceScore} / 10
        </c:if>
    </div>
</div>
<div class="rating-guide-bubble" id="violence-guide" aria-live="polite"></div>
</div>

<style>
    .rating-guide-wrap {
        position: relative;
        display: inline-block;
        max-width: 100%;
    }

    .circle-wrapper {
        position: relative;
        display: inline-block;
        width: 1.08em;
        height: 1.08em;
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

    #violence-score-rating .rating-icon {
        position: absolute;
        left: 0;
        top: 0;
        display: block;
        width: 100%;
        height: 100%;
        font-size: 0.9em;
        line-height: 1;
        overflow: hidden;
        pointer-events: none;
    }

    #violence-score-rating .rating-icon-empty {
        color: #ddd;
    }

    #violence-score-rating .rating-icon-fill {
        color: #e54b4b;
        width: 0;
        transition: width 0.12s ease;
    }

    #violence-score-rating .fa-regular.fa-circle { color: #ccc; }
    #violence-score-rating .fa-solid.fa-circle,
    #violence-score-rating .fa-solid.fa-circle-half-stroke {
        color: #e54b4b; /* 폭력성 점수: 빨간색 */
    }

    #violence-guide.rating-guide-bubble {
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

    #violence-guide.rating-guide-bubble.is-visible {
        opacity: 1;
        visibility: visible;
        transform: translateY(0);
    }

    #violence-guide.rating-guide-bubble::before {
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
    
    /* 반응형 지원 */
    @media (max-width: 576px) {
        #violence-score-rating {
            font-size: 1.2rem; /* 모바일에서는 조금 더 작게 */
        }
        
        #violence-label {
            font-size: 0.8rem;
        }

        #violence-guide.rating-guide-bubble {
            max-width: calc(100vw - 32px);
            font-size: 0.78rem;
        }
    }
</style>


<script>
document.addEventListener("DOMContentLoaded", function () {
    const movieId = document.getElementById("movieId")?.value;
    const contextPath = '${pageContext.request.contextPath}';
    const halves = document.querySelectorAll("#violence-score-rating .half");
    const icons = document.querySelectorAll("#violence-score-rating .rating-icon-fill");
    const label = document.getElementById("violence-label");
    const guide = document.getElementById("violence-guide");
    const violenceGuideMessages = [
        { max: 1, text: "폭력적인 장면이 없어요." },
        { max: 2, text: "폭력적인 느낌이 아주 약해요." },
        { max: 4, text: "폭력적인 장면이 조금 신경 쓰여요." },
        { max: 6, text: "폭력적인 장면이 꽤 뚜렷해요." },
        { max: 8, text: "폭력적인 장면이 강하게 느껴져요." },
        { max: 10, text: "보기 힘들 만큼 폭력적이에요." }
    ];
    let currentScore = violenceScore;

    if (currentScore > 0) {
        updateCircles(currentScore);
        label.textContent = currentScore + " / 10";
    } else {
        label.textContent = "";
    }
    hideRatingGuide();

    halves.forEach(half => {
        half.addEventListener("mouseover", function () {
            const previewScore = parseInt(this.dataset.value);
            updateCircles(previewScore);
            label.textContent = previewScore + " / 10";
            showRatingGuide(previewScore);
        });
    });

    document.getElementById("violence-score-rating").addEventListener("mouseleave", function () {
        updateCircles(currentScore);
        if (currentScore > 0) {
            label.textContent = currentScore + " / 10";
        } else {
            label.textContent = "";
        }
        hideRatingGuide();
    });

    halves.forEach(half => {
        half.addEventListener("click", function () {
            const isLoggedIn = document.getElementById("isLoggedIn")?.value === "true";
            if (!isLoggedIn) {
                alert("로그인 후 이용 가능합니다.");
                return;
            }
            const score = parseInt(this.dataset.value);
            currentScore = score;
            updateCircles(score);
            label.textContent = score + " / 10";
            showRatingGuide(score);
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

    function updateCircles(score) {
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
        const guideMessage = violenceGuideMessages.find(item => score <= item.max);
        return guideMessage ? guideMessage.text : "";
    }
});
</script>
