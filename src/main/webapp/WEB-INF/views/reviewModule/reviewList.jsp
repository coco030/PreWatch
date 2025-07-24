<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<% System.out.println("다른 사용자의 리뷰 리스트 진입"); %>
<hr>
<h5>모든 리뷰</h5>

<c:forEach var="review" items="${reviewList}">
    <c:if test="${not empty review.reviewContent}">
        <div class="review-item">
            <p>
                <strong>${review.memberId}</strong>님이
                <span>${review.createdAt}</span>에 작성하신 리뷰
            </p>
            <p>${fn:escapeXml(review.reviewContent)}</p>
        </div>
        <hr>
    </c:if>
</c:forEach>
