<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<% System.out.println("다른 사용자의 리뷰 리스트 진입"); %>
<hr>
<%-- 다른 사용자 리뷰 목록 --%>
<c:forEach var="review" items="${reviewList}">
    <c:if test="${empty myReview or review.memberId ne myReview.memberId}">
        <c:if test="${not empty review.reviewContent}">
            <div class="review-item">
                <p><strong>${review.memberId}</strong>님이 ${review.createdAt}에 작성하신 리뷰  </p>
				<p>${review.reviewContent}</p>
            </div>
            <hr>
        </c:if>
    </c:if>
</c:forEach>
