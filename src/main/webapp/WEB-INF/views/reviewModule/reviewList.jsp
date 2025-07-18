<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<% System.out.println("리뷰 리스트 진입"); %>

<%-- 내 리뷰 영역  --%>
<c:if test="${not empty sessionScope.loginMember}">
  <c:choose>
    <c:when test="${not empty myReview}">
       <!-- 내 리뷰가 존재할 경우 출력 -->
       <div class="my-review-box">
           <h4>내 리뷰</h4>
           <p><strong>별점:</strong> ${myReview.userRating} / 10</p>
           <p><strong>폭력성:</strong> ${myReview.violenceScore} / 10</p>
           <p>${myReview.reviewContent}</p>
           <c:if test="${not empty myReview.tags}">
               <p style="color:gray; font-size:0.85em">#${fn:replace(myReview.tags, ',', ' #')}</p>
           </c:if>
       </div>
    </c:when>
    <c:otherwise>
       <p style="color:gray;">아직 리뷰를 작성하지 않으셨습니다.</p>
    </c:otherwise>
  </c:choose>
</c:if>

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
