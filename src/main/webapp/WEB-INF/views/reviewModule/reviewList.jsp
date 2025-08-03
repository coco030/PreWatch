<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<% System.out.println("다른 사용자의 리뷰 리스트 진입"); %>
<style>
.spaced-date {
    margin-left: 10px;
}
</style>

<c:set var="validReviewCount" value="0" />

<c:forEach var="review" items="${reviewList}">
    <c:if test="${not empty review.reviewContent}">
        <c:set var="validReviewCount" value="${validReviewCount + 1}" />
        <div class="review-item">
            <p>
                <strong>${review.memberId}</strong>님     
                <span class="created-at spaced-date" data-created-at="${review.createdAt}"></span>
            </p>
            <p>${fn:escapeXml(review.reviewContent)}</p>
        </div>
        <hr>
    </c:if>
</c:forEach>

<!-- 출력된 유효 코멘트가 없으면 안내 문구 출력 -->
<c:if test="${validReviewCount == 0}">
    <div class="text-muted small mt-2"></div>
</c:if>

<script>
    document.querySelectorAll('.created-at').forEach(function(el) {
        const raw = el.dataset.createdAt;
        if (!raw) return;
        const date = new Date(raw);
        const formatted = date.getFullYear() + '.' +
                          String(date.getMonth() + 1).padStart(2, '0') + '.' +
                          String(date.getDate()).padStart(2, '0') + ' ' +
                          String(date.getHours()).padStart(2, '0') + ':' +
                          String(date.getMinutes()).padStart(2, '0');
        el.textContent = formatted;
    });
</script>