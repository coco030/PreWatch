<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<div class="rating-guide-wrap">
    <div id="violence-score-rating"
         class="prewatch-rating d-flex align-items-center"
         style="--rating-fill-color: #e54b4b; --rating-font-size: 1.5rem; --rating-mobile-font-size: 1.2rem; --rating-icon-size: 0.9em;">
        <c:forEach begin="1" end="5" var="i">
            <span class="prewatch-rating-token me-1" data-index="${i}">
                <span class="half left-half" data-value="${i * 2 - 1}"></span>
                <span class="half right-half" data-value="${i * 2}"></span>
                <span class="rating-icon rating-icon-empty" aria-hidden="true">●</span>
                <span class="rating-icon rating-icon-fill" aria-hidden="true">●</span>
            </span>
        </c:forEach>

        <div class="prewatch-rating-label ms-2" id="violence-label" style="font-size: 0.9rem;">
            <c:if test="${not empty myReview.violenceScore}">
                ${myReview.violenceScore} / 10
            </c:if>
        </div>
    </div>
    <div class="rating-guide-bubble" id="violence-guide" aria-live="polite"></div>
</div>

<script>
window.PrewatchRatingForm && window.PrewatchRatingForm.init({
    containerId: "violence-score-rating",
    labelId: "violence-label",
    guideId: "violence-guide",
    contextPath: "${pageContext.request.contextPath}",
    movieId: "${movieId}",
    initialScore: Number("${myReview.violenceScore}"),
    isLoggedIn: ${not empty loginMember},
    savePath: "/review/saveViolence",
    scoreParam: "violenceScore",
    successLog: "폭력성 점수 저장 성공:",
    errorLog: "폭력성 점수 저장 실패:",
    messages: [
        { max: 1, text: "폭력적인 장면이 없어요." },
        { max: 2, text: "폭력적인 느낌이 아주 약해요." },
        { max: 4, text: "폭력적인 장면이 조금 신경 쓰여요." },
        { max: 6, text: "폭력적인 장면이 꽤 뚜렷해요." },
        { max: 8, text: "폭력적인 장면이 강하게 느껴져요." },
        { max: 10, text: "보기 힘들 만큼 폭력적이에요." }
    ]
});
</script>
