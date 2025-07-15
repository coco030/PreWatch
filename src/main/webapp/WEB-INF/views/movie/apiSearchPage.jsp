<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<html>
<head>
    <title>API에서 영화 검색</title>
    <style>
        table { width: 100%; border-collapse: collapse; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        img { max-width: 80px; height: auto; }
    </style>
</head>
<body>
    <h1>API에서 영화 검색</h1>

    <form action="<c:url value='/search'/>" method="get">
        영화 제목 또는 키워드: <input type="text" name="query" value="${query}" placeholder="영화 검색..." />
        <button type="submit">검색</button>
    </form>

    <hr>

    <c:if test="${searchPerformed}">
        <c:if test="${not empty param.error && param.error == 'detailNotFound'}">
            <p style="color: red;">선택하신 영화의 상세 정보를 가져오거나 등록할 수 없었습니다.</p>
        </c:if>
        
        <h2>"${query}" 검색 결과</h2>
        <c:if test="${empty apiMovies}">
            <p>검색 결과가 없습니다. 다른 키워드로 검색해보세요.</p>
        </c:if>
        <c:if test="${not empty apiMovies}">
            <table>
                <thead>
                    <tr>
                        <th>포스터</th>
                        <th>제목</th>
                        <th>연도</th>
                        <th>IMDb ID</th>
                        <%-- '동작' 열도 관리자에게만 보이도록 함 --%>
                        <c:if test="${userRole == 'ADMIN'}">
                            <th>동작</th>
                        </c:if>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="apiMovie" items="${apiMovies}">
                        <tr>
                            <td>
                                <c:choose>
                                    <c:when test="${not empty apiMovie.posterPath and apiMovie.posterPath ne 'N/A'}">
                                        <img src="${apiMovie.posterPath}" alt="${apiMovie.title} 포스터" />
                                    </c:when>
                                    <c:otherwise>
                                        <img src="<c:url value='/resources/images/default_poster.jpg'/>" alt="기본 포스터" />
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>${apiMovie.title}</td>
                            <td>${apiMovie.year}</td>
                            <td>${apiMovie.apiId}</td>
                            <%-- '이 영화 등록' 버튼을 관리자에게만 보이도록 함 ⭐수정 필요⭐ --%>
                            <c:if test="${userRole == 'ADMIN'}">
                                <td>
                                    <form action="<c:url value='/movies/import-api-detail'/>" method="post" style="display:inline;">
                                        <input type="hidden" name="imdbId" value="${apiMovie.apiId}" />
                                        <button type="submit">이 영화 등록</button>
                                    </form>
                                </td>
                            </c:if>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </c:if>
    </c:if>

    <p><a href="<c:url value='/movies'/>">내 영화 목록으로 돌아가기</a></p>
</body>
</html>