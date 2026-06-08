<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<div class="rating-guide-wrap">
    <div id="star-rating"
         class="prewatch-rating d-flex align-items-center"
         style="--rating-fill-color: #ffc107; --rating-font-size: 1.5rem; --rating-mobile-font-size: 1rem;">
        <c:forEach begin="1" end="5" var="i">
            <span class="prewatch-rating-token me-1" data-index="${i}">
                <span class="half left-half" data-value="${i * 2 - 1}"></span>
                <span class="half right-half" data-value="${i * 2}"></span>
                <span class="rating-icon rating-icon-empty" aria-hidden="true">★</span>
                <span class="rating-icon rating-icon-fill" aria-hidden="true">★</span>
            </span>
        </c:forEach>

        <div class="prewatch-rating-label ms-2" id="rating-label" style="font-size: 0.9rem; font-weight: 500;">
            <c:if test="${not empty myReview.userRating}">
                ${myReview.userRating} / 10
            </c:if>
        </div>
    </div>
    <div class="rating-guide-bubble" id="user-rating-guide" aria-live="polite"></div>
</div>

<script>
window.PrewatchRatingForm && window.PrewatchRatingForm.init({
    containerId: "star-rating",
    labelId: "rating-label",
    guideId: "user-rating-guide",
    contextPath: "${pageContext.request.contextPath}",
    movieId: "${movieId}",
    initialScore: Number("${myReview.userRating}"),
    isLoggedIn: ${not empty loginMember},
    savePath: "/review/saveRating",
    scoreParam: "userRating",
    emptyLabel: "평가하기",
    successLog: "저장 성공:",
    errorLog: "저장 실패:",
    errorMessage: "별점 저장에 실패했습니다. 다시 시도해 주세요.",
    messages: [
        { max: 1, text: "다신 보고 싶지 않아요." },
        { max: 2, text: "좋았던 점을 찾기 어려운 영화예요." },
        { max: 4, text: "아쉬운 점이 더 크게 남는 영화예요." },
        { max: 6, text: "무난하지만 강한 인상은 적은 편이에요." },
        { max: 8, text: "꽤 만족스럽고 추천할 만해요." },
        { max: 10, text: "취향에 잘 맞고 다시 보고 싶은 영화예요." }
    ]
});
</script>
