<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<html>
<head><title>영화 목록</title></head>
<body>
<h1>영화 목록</h1>

<%-- 관리자에게만 보이는 링크 --%>
<c:if test="${userRole == 'ADMIN'}">
    <p><a href="<c:url value='/movies/search-api'/>">API에서 영화 검색 및 등록</a></p>
    <p><a href="<c:url value='/movies/new'/>">새 영화 직접 등록</a></p>
</c:if>

<c:if test="${not empty param.error}">
    <p style="color: red;">${param.error == 'notFound' ? '요청하신 영화를 찾을 수 없습니다.' : (param.error == 'movieNotFound' ? '영화 정보를 찾을 수 없거나 API 호출에 실패했습니다.' : '알 수 없는 오류가 발생했습니다.')}</p>
</c:if>
<c:if test="${not empty param.status && param.status == 'registered'}">
    <p style="color: green;">API에서 영화 정보가 성공적으로 등록되었습니다!</p>
</c:if>

<table border="1">
    <tr>
        <th>포스터</th>
        <th>제목</th>
        <th>감독</th>
        <th>연도</th>
        <th>장르</th>
        <th>평점</th>
        <th>잔혹도</th>
        <th>개요</th>
        <%-- 관리자에게만 '관리' 열 표시 --%>
        <c:if test="${userRole == 'ADMIN'}">
            <th>관리</th>
        </c:if>
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
            <td><fmt:formatNumber value="${movie.rating}" pattern="#0.0" /></td>
            <td><fmt:formatNumber value="${movie.violence_score_avg}" pattern="#0.0" /></td>
            <td>${fn:substring(movie.overview, 0, 30)}...</td>
            <%-- 관리자에게만 '수정'/'삭제' 버튼 표시 --%>
            <c:if test="${userRole == 'ADMIN'}">
                <td>
                    <a href="<c:url value='/movies/${movie.id}/edit'/>">수정</a>
                    <form action="<c:url value='/movies/${movie.id}/delete'/>" method="post" style="display:inline">
                        <button type="submit">삭제</button>
                    </form>
                </td>
            </c:if>
        </tr>
    </c:forEach>
    <c:if test="${empty movies}">
        <tr>
            <%-- colspan 값 조정 (관리자 열 유무에 따라) --%>
            <c:choose>
                <c:when test="${userRole == 'ADMIN'}">
                    <td colspan="9">등록된 영화가 없습니다.</td>
                </c:when>
                <c:otherwise>
                    <td colspan="8">등록된 영화가 없습니다.</td>
                </c:otherwise>
            </c:choose>
        </tr>
    </c:if>
</table>
</body>
</html>