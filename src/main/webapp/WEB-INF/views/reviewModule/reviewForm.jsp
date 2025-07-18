<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%System.out.println("reviewForm 진입"); %>
<c:if test="${empty sessionScope.loginMember}">
    <script>
        alert("로그인 후 이용 가능한 기능입니다.");
        location.href = '${pageContext.request.contextPath}/auth/login';
    </script>
</c:if>

<form action="${pageContext.request.contextPath}/review/save" method="post">

    <input type="hidden" name="movieId" value="${movieId}" />

    <label>영화만족도 (1~10):</label>
    <input type="number" name="userRating" min="1" max="10"
           value="${myReview.userRating}" />

    <label>잔혹도 (1~10):</label>
    <input type="number" name="violenceScore" min="1" max="10"
           value="${myReview.violenceScore}" />

    <label>리뷰:</label>
    <textarea name="reviewContent">${myReview.reviewContent}</textarea>

    <label>태그 (쉼표로 구분):</label>
    <input type="text" name="tags" value="${myReview.tags}" />

    <button type="submit">리뷰 저장</button>
</form>
