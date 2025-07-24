<%--  
    파일명: list.jsp  
    설명:  
        이 JSP 파일은 데이터베이스에 등록된 모든 영화 목록을 표시하는 페이지입니다.  
        각 영화의 포스터, 제목, 감독, 연도, 장르, 평점, 폭력성 평균, 개요(요약), IMDb ID를 보여줍니다.  
        관리자는 이 페이지에서 영화를 '수정'하거나 '삭제'할 수 있는 버튼을 추가로 볼 수 있습니다.  
        로그인한 일반 사용자에게는 찜(하트) 기능을 제공합니다.  
        각 영화 아래에 찜 아이콘 및 찜 개수를 표시합니다.  
    목적:  
        - 시스템에 등록된 모든 영화 정보를 한눈에 볼 수 있도록 합니다.  
        - 영화 제목 클릭 시 상세 페이지로 이동하여 더 많은 정보를 확인하도록 유도합니다.  
        - 관리자에게는 등록된 영화를 직접 관리(수정, 삭제)할 수 있는 기능을 제공합니다.  
        - API에서 가져온 영화와 수동으로 등록된 영화 모두를 일관된 형식으로 표시합니다.  
        - 로그인한 사용자는 영화 찜 상태 확인 및 토글 기능을 사용할 수 있습니다.  
--%> 
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>  
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>  
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>  
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<head>
<title>영화 관리</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<c:url value='/resources/css/layout.css'/>">
<style>
    table { width: 100%; border-collapse: collapse; }
    th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
    img { max-width: 100px; height: auto; }
</style>
<html>
<%-- 헤더 --%>
<jsp:include page="/WEB-INF/views/layout/header.jsp" />
</head>
<body>
<h1>영화 관리</h1>

<c:if test="${userRole == 'ADMIN'}">
    <p><a href="<c:url value='/movies/new'/>">새 영화 직접 등록</a></p>
    <p><a href="<c:url value='/admin/banner-movies'/>">추천 영화 관리</a></p> <%-- (7-24 오후12:41 추가 된 코드) --%>
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
        <th>폭력성</th>
        <th>개요</th>
        <th>IMDb ID</th>
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
                            <c:set var="posterSrc" value="${pageContext.request.contextPath}/resources/images/movies/256px-No-Image-Placeholder.png" />
                        </c:otherwise>
                    </c:choose>
                </c:set>
                <img src="${posterSrc}" alt="${movie.title} 포스터" />
            </td>
            <td>
                <a href="<c:url value='/movies/${movie.id}'/>">${movie.title}</a>
            </td>
            <td>${movie.director}</td>
            <td>${movie.year}</td>
            <td>${movie.genre}</td>
            <td>
                <c:choose>
                    <c:when test="${movie.rating == 0.0}">
                        N/A
                    </c:when>
                    <c:otherwise>
                        <fmt:formatNumber value="${movie.rating}" pattern="#0.0" />
                    </c:otherwise>
                </c:choose>
            </td>
            <td>
                <c:choose>
                    <c:when test="${movie.violence_score_avg == 0.0}">
                        N/A
                    </c:when>
                    <c:otherwise>
                        <fmt:formatNumber value="${movie.violence_score_avg}" pattern="#0.0" />
                    </c:otherwise>
                </c:choose>
            </td>
            <td>${fn:substring(movie.overview, 0, 30)}...</td>
            <td>${movie.apiId}</td>
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
            <c:choose>
                <c:when test="${userRole == 'ADMIN'}">
                    <td colspan="10">등록된 영화가 없습니다.</td>
                </c:when>
                <c:otherwise>
                    <td colspan="9">등록된 영화가 없습니다.</td>
                </c:otherwise>
            </c:choose>
        </tr>
    </c:if>
</table>
    <%-- 푸터 삽입 위치: body 안쪽 --%>
    <jsp:include page="/WEB-INF/views/layout/footer.jsp" />
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
</body>