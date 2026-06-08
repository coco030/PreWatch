<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<div class="rating-guide-wrap">
    <div id="horrorScore-rating"
         class="prewatch-rating d-flex align-items-center"
         style="--rating-fill-color: #4682B4; --rating-font-size: 1.5rem; --rating-mobile-font-size: 1rem;">
        <c:forEach begin="1" end="5" var="i">
            <span class="prewatch-rating-token me-1" data-index="${i}">
                <span class="half left-half" data-value="${i * 2 - 1}"></span>
                <span class="half right-half" data-value="${i * 2}"></span>
                <span class="rating-icon rating-icon-empty" aria-hidden="true">★</span>
                <span class="rating-icon rating-icon-fill" aria-hidden="true">★</span>
            </span>
        </c:forEach>

        <div class="prewatch-rating-label ms-2" id="horror-label" style="font-size: 0.9rem; font-weight: 500;">
            <c:if test="${not empty myReview.horrorScore}">
                ${myReview.horrorScore} / 10
            </c:if>
        </div>
    </div>
    <div class="rating-guide-bubble" id="horror-guide" aria-live="polite"></div>
</div>

<script>
window.PrewatchRatingForm && window.PrewatchRatingForm.init({
    containerId: "horrorScore-rating",
    labelId: "horror-label",
    guideId: "horror-guide",
    contextPath: "${pageContext.request.contextPath}",
    movieId: "${movieId}",
    initialScore: Number("${myReview.horrorScore}"),
    isLoggedIn: ${not empty loginMember},
    savePath: "/review/saveHorrorUserScore",
    scoreParam: "horrorScore",
    successLog: "공포 점수 저장 응답:",
    errorLog: "공포 점수 저장 중 오류:",
    messages: [
        { max: 1, text: "무섭거나 불안한 장면이 거의 없어요." },
        { max: 2, text: "무섭기보다 긴장감이 약한 수준이에요." },
        { max: 4, text: "어두운 분위기나 약한 놀람 요소가 있어요." },
        { max: 6, text: "긴장감, 불안감, 점프스케어가 있어요." },
        { max: 8, text: "심리적 압박이나 공포 장면이 강해요." },
        { max: 10, text: "보는 내내 불쾌감이나 공포감이 크게 남아요." }
    ]
});
</script>
