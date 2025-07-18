<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%System.out.println("reviewTagAll 진입"); %>
<!-- reviewModule/reviewTagAll.jsp -->
<!-- 영화 상세페이지 하단에 태그 전체 출력하는 영역 -->
<!-- 전체 태그 출력용: 특정 영화의 모든 리뷰에서 태그만 추출 -->
<c:forEach var="review" items="${reviewList}">
    <c:if test="${not empty review.tags}">
        <c:set var="tagsArray" value="${fn:split(review.tags, ',')}" />
        <c:forEach var="tag" items="${tagsArray}">
            <c:if test="${not empty tag}">
                <span class="badge bg-secondary">#${tag}</span>
            </c:if>
        </c:forEach>
    </c:if>
</c:forEach>
<!-- // 영화 상세페이지 하단에 태그 전체 출력하는 영역 -->