<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<html>
<head><title>영화 상세</title></head>
<body>
<h1>${movie.title}</h1>

<%-- 포스터 이미지 표시 로직 --%>
<c:if test="${not empty movie.posterPath and movie.posterPath ne 'N/A'}">
    <c:set var="posterSrc">
        <c:choose>
            <c:when test="${fn:startsWith(movie.posterPath, 'http://') or fn:startsWith(movie.posterPath, 'https://')}">
                ${movie.posterPath}
            </c:when>
            <c:otherwise>
                ${pageContext.request.contextPath}${movie.posterPath}
            </c:otherwise>
        </c:choose>
    </c:set>
    <img src="${posterSrc}" alt="${movie.title} 포스터" style="max-width: 300px; height: auto;" /><br/>
</c:if>
<c:if test="${empty movie.posterPath or movie.posterPath eq 'N/A'}">
    <p>(이미지 없음)</p>
</c:if>

<p>감독: ${movie.director}</p>
<p>연도: ${movie.year}</p>
<p>장르: ${movie.genre}</p>
<p>평점: ${movie.rating} / 5.0</p>
<p>개요: ${movie.overview}</p>
<p>리뷰: ${movie.review}</p> 

<a href="<c:url value='/movies'/>">목록</a>
<a href="<c:url value='/movies/${movie.id}/edit'/>">수정</a>
<form action="<c:url value='/movies/${movie.id}/delete'/>" method="post" style="display:inline">
    <button type="submit">삭제</button>
</form>
</body>
</html>