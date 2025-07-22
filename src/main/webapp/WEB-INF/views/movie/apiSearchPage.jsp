<%--
    파일명: apiSearchPage.jsp
    설명:
        이 JSP 파일은 OMDb API를 통해 영화를 검색하고, 그 결과를 표시하는 페이지입니다.
        일반 사용자와 관리자 모두 접근하여 영화를 검색할 수 있지만, API에서 검색된 영화를 데이터베이스에 등록하는 기능은 관리자에게만 제공됩니다.
        또한, 외부 API에서 가져온 영화 정보라도 로컬 DB에 동일한 영화가 있을 경우, 로컬 DB의 평점 및 잔혹도 평균으로 덮어씌워 표시합니다.

    목적:
        - 사용자가 외부 API(OMDb)를 통해 영화 정보를 검색할 수 있도록 제공하기 위해

--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<html>
<head>
    <meta charset="UTF-8">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<c:url value='/resources/css/layout.css'/>">
</head> 
<%-- 헤더 --%>
<jsp:include page="/WEB-INF/views/layout/header.jsp" />
    <title>영화 검색</title>
    <style>
        table { width: 100%; border-collapse: collapse; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        img { max-width: 80px; height: auto; }
    </style>
</head>
<body>
    <c:if test="${userRole == 'ADMIN'}">
        <p><a href="<c:url value='/movies'/>">내 영화 관리페이지로 돌아가기</a></p>
    </c:if> 
    <hr>

    <c:if test="${searchPerformed}">

        <c:if test="${not empty param.error && param.error == 'detailNotFound'}">
            <p style="color: red;">선택하신 영화의 상세 정보를 가져오거나 등록할 수 없었습니다.</p>
        </c:if>

        <h2>"${query}" 검색 결과</h2>
        <c:if test="${empty apiMovies}">
            <p>검색 결과가 없습니다. 다른 키워드로 검색해보세요.</p>
        </c:if>
        <%--
            검색 결과가 있는 경우
            `apiMovies` 리스트를 반복하여 각 영화 정보를 테이블 행으로 표시합니다.
        --%>
        <c:if test="${not empty apiMovies}">
            <table>
                <thead>
                    <tr>
                        <th>포스터</th>
                        <th>제목</th>
                        <th>감독</th>
                        <th>연도</th>
                        <th>장르</th>
                        <th>평점</th>
                        <th>폭력성</th>
                        <th>개요</th>
                        <%-- '동작' 열도 관리자에게만 보이도록 함--%>
                        <c:if test="${userRole == 'ADMIN'}">
                            <th>IMDb ID</th>
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
                                                         <%--  이미지 출처는 https://commons.wikimedia.org/wiki/File:No-Image-Placeholder.svg --%>
                                        <img src="<c:url value='/resources/images/movies/256px-No-Image-Placeholder.png'/>" alt="기본 포스터" />
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <a href="<c:url value='/movies/api-external-detail?imdbId=${apiMovie.apiId}'/>" class="title-as-link">
                                    ${apiMovie.title}
                                </a>
                            </td>
                            <%-- 영화 정보 표시--%>
                            <td>${apiMovie.director}</td>
                            <td>${apiMovie.year}</td>
                            <td>${apiMovie.genre}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${apiMovie.rating == 0.0}">
                                        N/A 
                                    </c:when>
                                    <c:otherwise>
                                        <fmt:formatNumber value="${apiMovie.rating}" pattern="#0.0" />
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${apiMovie.violence_score_avg == 0.0}">
                                        N/A <%-- 폭력성 평균이 0.0이면 N/A 표시--%>
                                    </c:when>
                                    <c:otherwise>
                                        <fmt:formatNumber value="${apiMovie.violence_score_avg}" pattern="#0.0" />
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>${fn:substring(apiMovie.overview, 0, 30)}...</td>
                            <%-- 관리자에게만 'IMDb ID'와 '동작' (영화 등록 버튼) 표시--%>
                            <c:if test="${userRole == 'ADMIN'}">
                                <td>${apiMovie.apiId}</td>
                                <td>
                                    <form action="<c:url value='/movies/import-api-detail'/>" method="post" style="display:inline;">
                                        <input type="hidden" name="imdbId" value="${apiMovie.apiId}" /><button type="submit">이 영화 등록</button>
                                    </form>
                                </td>
                            </c:if>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </c:if>
    </c:if>
     <%-- 푸터 --%>
    <jsp:include page="/WEB-INF/views/layout/footer.jsp" />
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
</body>
</html>