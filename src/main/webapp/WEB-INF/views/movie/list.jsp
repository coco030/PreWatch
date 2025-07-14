<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<html>
<head><title>영화 목록</title></head>
<body>
<h1>영화 목록</h1>
<form action="<c:url value='/movies/import'/>" method="post">
    영화 제목: <input type="text" name="title" />
    <button type="submit">검색</button>
</form>

<c:if test="${not empty param.error}">
    <p style="color: red;">${param.error == 'movieNotFound' ? '영화 정보를 찾을 수 없거나 API 호출에 실패했습니다.' : '알 수 없는 오류가 발생했습니다.'}</p>
</c:if>

<a href="<c:url value='/movies/new'/>">새 영화 등록</a>
<table border="1">
    <tr>
        <th>포스터</th>
        <th>제목</th>
        <th>감독</th>
        <th>연도</th>
        <th>장르</th>
        <th>평점</th>
        <th>개요</th>
        <th>리뷰</th> 
    </tr>
    <c:forEach var="movie" items="${movies}">
        <tr>
            <td>
                <c:set var="posterSrc">
                    <c:choose>
                        <c:when test="${not empty movie.posterPath and movie.posterPath ne 'N/A'}">
                            <c:if test="${fn:startsWith(movie.posterPath, 'http://') or fn:startsWith(movie.posterPath, 'https://')}">
                                ${movie.posterPath}
                            </c:if>
                            <c:if test="${not (fn:startsWith(movie.posterPath, 'http://') or fn:startsWith(movie.posterPath, 'https://'))}">
                                ${pageContext.request.contextPath}${movie.posterPath}
                            </c:if>
                        </c:when>
                        <c:otherwise>
                            ${pageContext.request.contextPath}/resources/images/default_poster.jpg
                        </c:otherwise>
                    </c:choose>
                </c:set>
                <img src="${posterSrc}" alt="${movie.title} 포스터" style="width: 100px; height: auto;" />
            </td>
            <td><a href="<c:url value='/movies/${movie.id}'/>">${movie.title}</a></td>
            <td>${movie.director}</td>
            <td>${movie.year}</td>
            <td>${movie.genre}</td>
            <td>${movie.rating}</td>
            <td>${fn:substring(movie.overview, 0, 30)}...</td>
            <td>${fn:substring(movie.review, 0, 30)}...</td> 
            <td>
                <a href="<c:url value='/movies/${movie.id}/edit'/>">수정</a>
                <form action="<c:url value='/movies/${movie.id}/delete'/>" method="post" style="display:inline">
                    <button type="submit">삭제</button>
                </form>
            </td>
        </tr>
    </c:forEach>
    <c:if test="${empty movies}">
        <tr><td colspan="8">등록된 영화가 없습니다.</td></tr> <%-- colspan 갯수 조정 --%>
    </c:if>
</table>
</body>
</html>