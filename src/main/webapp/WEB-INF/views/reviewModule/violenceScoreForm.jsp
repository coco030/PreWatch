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

<div id="violence-score-rating" class="d-flex align-items-center" style="font-size: 1.5rem;">
    <c:forEach begin="1" end="5" var="i">
        <span class="circle-wrapper me-1" data-index="${i}">
            <span class="half left-half" data-value="${i * 2 - 1}"></span>
            <span class="half right-half" data-value="${i * 2}"></span>
            <i class="fa-regular fa-circle"></i>
        </span>
    </c:forEach>

    <div class="ms-2" id="violence-label" style="font-size: 0.9rem;">
        <c:if test="${not empty myReview.violenceScore}">
            ${myReview.violenceScore} / 10
        </c:if>
    </div>
</div>

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

    #violence-score-rating .fa-regular.fa-circle { color: #ccc; }
    #violence-score-rating .fa-solid.fa-circle,
    #violence-score-rating .fa-solid.fa-circle-half-stroke {
        color: #e54b4b; /* 폭력성 점수: 빨간색 */
    }
    
    /* 반응형 지원 */
    @media (max-width: 576px) {
        #violence-score-rating {
            font-size: 1.2rem; /* 모바일에서는 조금 더 작게 */
        }
        
        #violence-label {
            font-size: 0.8rem;
        }
    }
</style>


<script>
document.addEventListener("DOMContentLoaded", function () {
    const movieId = document.getElementById("movieId")?.value;
    const contextPath = '${pageContext.request.contextPath}';
    const halves = document.querySelectorAll("#violence-score-rating .half");
    const icons = document.querySelectorAll("#violence-score-rating i");
    const label = document.getElementById("violence-label");
    let currentScore = violenceScore;

    if (currentScore > 0) {
        updateCircles(currentScore);
        label.textContent = currentScore + " / 10";
    } else {
        label.textContent = "";
    }

    halves.forEach(half => {
        half.addEventListener("mouseover", function () {
            const previewScore = parseInt(this.dataset.value);
            updateCircles(previewScore);
            label.textContent = previewScore + " / 10";
        });
    });

    document.getElementById("violence-score-rating").addEventListener("mouseleave", function () {
        updateCircles(currentScore);
        if (currentScore > 0) {
            label.textContent = currentScore + " / 10";
        } else {
            label.textContent = "";
        }
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
            icon.classList.remove("fa-solid", "fa-regular", "fa-circle", "fa-circle-half-stroke");
            if (score >= value) {
                icon.classList.add("fa-solid", "fa-circle");
            } else if (score === value - 1) {
                icon.classList.add("fa-solid", "fa-circle-half-stroke");
            } else {
                icon.classList.add("fa-regular", "fa-circle");
            }
        });
    }
});
</script>