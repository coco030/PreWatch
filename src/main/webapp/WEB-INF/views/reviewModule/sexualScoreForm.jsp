<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<!-- jQuery CDN (AJAX 및 이벤트 핸들용) -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<!-- Font Awesome 아이콘 (원형 아이콘 표시용) -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

<!-- ⭐ 영화 ID 및 초기 점수 -->
<input type="hidden" id="movieId" value="${movieId}" />
<c:if test="${not empty loginMember}">
    <input type="hidden" id="isLoggedIn" value="true" />
</c:if>
<script>
    const sexualScore = Number("${myReview.sexualScore}");
</script>

<!-- ⭐ 선정성 점수 표시 영역 -->
<div id="sexualScore-rating" class="d-flex align-items-center" style="font-size: 2rem;">
    <c:forEach begin="1" end="5" var="i">
        <span class="circle-wrapper me-1" data-index="${i}">
            <span class="half left-half" data-value="${i * 2 - 1}"></span>
            <span class="half right-half" data-value="${i * 2}"></span>
            <i class="fa-regular fa-circle"></i>
        </span>
    </c:forEach>

    <!-- 점수 라벨 -->
    <div class="ms-2" id="sexualScore-label" style="font-size: 1rem;">
        <c:if test="${not empty myReview.sexualScore}">
            ${myReview.sexualScore} / 10
        </c:if>
    </div>
</div>

<!-- ⭐ CSS (보라색 원 스타일) -->
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

    #sexualScore-rating .fa-regular.fa-circle { color: #ccc; }

    #sexualScore-rating .fa-solid.fa-circle,
    #sexualScore-rating .fa-solid.fa-circle-half-stroke {
        color: #9B59B6; /* 선정성 점수: 보라색 */
    }
</style>

<!-- ⭐ 선정성 점수 스크립트 (hover, click, 저장) -->
<script>
document.addEventListener("DOMContentLoaded", function () {
    const movieId = document.getElementById("movieId")?.value;
    const contextPath = '${pageContext.request.contextPath}';
    const halves = document.querySelectorAll("#sexualScore-rating .half");
    const icons = document.querySelectorAll("#sexualScore-rating i");
    const label = document.getElementById("sexualScore-label");

    let currentScore = sexualScore;

    // ⭐ 초기 렌더링
    if (currentScore > 0) {
        updateCircles(currentScore);
        label.textContent = currentScore + " / 10";
    } else {
        label.textContent = "";
    }

    // ⭐ hover 프리뷰
    halves.forEach(half => {
        half.addEventListener("mouseover", function () {
            const previewScore = parseInt(this.dataset.value);
            updateCircles(previewScore);
            label.textContent = previewScore + " / 10";
        });
    });

    // ⭐ mouseleave 복원
    document.getElementById("sexualScore-rating").addEventListener("mouseleave", function () {
        updateCircles(currentScore);
        if (currentScore > 0) {
            label.textContent = currentScore + " / 10";
        } else {
            label.textContent = "";
        }
    });

    // ⭐ 클릭 저장
halves.forEach(half => {
    half.addEventListener("click", function () {
        // ⭐ 로그인 여부 확인
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
        formData.append("sexualScore", score);

        fetch(contextPath + "/review/saveSexualUserScore", {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body: formData
        })
        .then(res => res.json())
        .then(data => {
            console.log("선정성 점수 저장 성공:", data);
        })
        .catch(err => {
            console.error("선정성 점수 저장 실패:", err);
        });
    });
});


    // ⭐ 원 아이콘 렌더링
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