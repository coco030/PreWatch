<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<div class="rating-guide-wrap">
    <div id="sexualScore-rating"
         class="prewatch-rating d-flex align-items-center"
         style="--rating-fill-color: #9B59B6; --rating-font-size: 1.5rem; --rating-mobile-font-size: 1.2rem; --rating-icon-size: 0.9em;">
        <c:forEach begin="1" end="5" var="i">
            <span class="prewatch-rating-token me-1" data-index="${i}">
                <span class="half left-half" data-value="${i * 2 - 1}"></span>
                <span class="half right-half" data-value="${i * 2}"></span>
                <span class="rating-icon rating-icon-empty" aria-hidden="true">●</span>
                <span class="rating-icon rating-icon-fill" aria-hidden="true">●</span>
            </span>
        </c:forEach>

        <div class="prewatch-rating-label ms-2" id="sexualScore-label" style="font-size: 0.9rem;">
            <c:if test="${not empty myReview.sexualScore}">
                ${myReview.sexualScore} / 10
            </c:if>
        </div>
    </div>
    <div class="rating-guide-bubble" id="sexual-guide" aria-live="polite"></div>
</div>

<script>
window.PrewatchRatingForm && window.PrewatchRatingForm.init({
    containerId: "sexualScore-rating",
    labelId: "sexualScore-label",
    guideId: "sexual-guide",
    contextPath: "${pageContext.request.contextPath}",
    movieId: "${movieId}",
    initialScore: Number("${myReview.sexualScore}"),
    isLoggedIn: ${not empty loginMember},
    savePath: "/review/saveSexualUserScore",
    scoreParam: "sexualScore",
    successLog: "선정성 점수 저장 성공:",
    errorLog: "선정성 점수 저장 실패:",
    messages: [
        { max: 1, text: "노출이나 성적 표현이 없어요." },
        { max: 2, text: "가족과 봐도 거의 부담 없는 수준이에요." },
        { max: 4, text: "가벼운 노출이나 성적 농담이 있어요." },
        { max: 6, text: "가족과 보기 민망할 수 있어요." },
        { max: 8, text: "노출이나 성적 장면이 뚜렷해요." },
        { max: 10, text: "노골적인 성적 표현이 강해요." }
    ]
});
</script>
