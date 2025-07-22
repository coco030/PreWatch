<%--
    파일명: mypage.jsp
    설명:
        이 JSP 파일은 로그인한 사용자의 마이페이지입니다.
        현재는 단순히 "나의 영화 리뷰나 별점 목록"이라는 텍스트만 표시하고 있으며,
        이 페이지에서 리뷰나 별점을 수정/삭제하는 기능은 제공하지 않는다고 명시되어 있습니다.

    목적:
        - 로그인한 사용자가 자신의 활동 기록(영화 리뷰, 별점 등)을 확인할 수 있는 개인 공간을 제공합니다.
        - 개인화된 경험의 시작점을 제시합니다.

--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<% System.out.println("mypage 뷰 진입"); %> <%-- 서버 콘솔에 페이지 진입 로그 출력 --%>

<head>
    <meta charset="UTF-8">
    <title>PreWatch: 상세</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<c:url value='/resources/css/layout.css'/>">
</head> 
<%-- 헤더 --%>
<jsp:include page="/WEB-INF/views/layout/header.jsp" />
<h2>${sessionScope.loginMember.id}님의 영화 기록</h2>

<c:forEach var="review" items="${myReviews}">
    <c:set var="movie" value="${movieMap[review.movieId]}" />

    <div>
        <!-- 제목 클릭 시 상세 페이지로 이동 -->
        <p>
        	<a href="${pageContext.request.contextPath}/movies/${movie.id}"><p>${movie.title}</p></a>
        </p>

        <!-- 포스터 클릭 시 상세 페이지로 이동 -->
        <c:if test="${not empty movie.posterPath}">
		    <a href="${pageContext.request.contextPath}/movies/${movie.id}"><img src="${movie.posterPath}" width="100" /></a>
		</c:if>

        <p>만족도: 
            <c:choose>
                <c:when test="${empty review.userRating}">(아직 만족도 평가를 하지 않으셨어요)</c:when>
                <c:otherwise>${review.userRating}점</c:otherwise>
            </c:choose>
        </p>

        <p>폭력성:
            <c:choose>
                <c:when test="${empty review.violenceScore}">(아직 폭력성 평가를 하지 않으셨어요)</c:when>
                <c:otherwise>${review.violenceScore}점</c:otherwise>
            </c:choose>
        </p>

        <p>리뷰:
            <c:choose>
                <c:when test="${empty review.reviewContent}">(아직 리뷰 작성을 하지 않으셨어요)</c:when>
                <c:otherwise>${review.reviewContent}</c:otherwise>
            </c:choose>
        </p>

        <p>태그:
            <c:choose>
                <c:when test="${empty review.tags}">(아직 태그 작성을 하지 않으셨어요)</c:when>
                <c:otherwise>${review.tags}</c:otherwise>
            </c:choose>
        </p>
    </div>
    <hr>
</c:forEach>
 <%-- 푸터 --%>
    <jsp:include page="/WEB-INF/views/layout/footer.jsp" />
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>