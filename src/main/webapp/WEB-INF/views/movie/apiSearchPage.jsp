<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>영화 검색</title>
    <link rel="stylesheet" href="<c:url value='/resources/css/layout.css'/>">
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f4f4f4;
            color: #333;
        }

        .container {
            width: 90%;
            margin: 20px auto;
            padding: 20px;
            background-color: #fff;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        }

        h2 {
            border-bottom: 2px solid #333;
            padding-bottom: 10px;
            margin-bottom: 20px;
        }

        .error-message {
            color: red;
            font-weight: bold;
            margin-bottom: 15px;
        }

        .no-results {
            color: #777;
            font-style: italic;
        }
        
        .movie-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }

        .movie-table th, .movie-table td {
            border: 1px solid #ddd;
            padding: 12px;
            text-align: left;
            vertical-align: middle;
        }

        .movie-table th {
            background-color: #333;
            color: white;
            font-weight: bold;
            text-transform: uppercase;
        }

        .movie-table tbody tr:nth-child(even) {
            background-color: #f9f9f9;
        }

        .movie-table tbody tr:hover {
            background-color: #f1f1f1;
        }

        .movie-poster {
            max-width: 80px;
            height: auto;
            display: block;
            border-radius: 4px;
        }

        .action-form {
            display: inline;
        }

        .action-button {
            background-color: #007bff;
            color: white;
            border: none;
            padding: 8px 12px;
            text-align: center;
            text-decoration: none;
            display: inline-block;
            font-size: 14px;
            margin: 4px 2px;
            cursor: pointer;
            border-radius: 4px;
            transition-duration: 0.4s;
        }

        .action-button:hover {
            background-color: #0056b3;
        }

        .back-link {
            text-align: right;
            margin-bottom: 15px;
        }

        .back-button {
            padding: 8px 16px;
            background-color: #6c757d;
            color: white;
            text-decoration: none;
            border-radius: 4px;
            transition: background-color 0.3s;
        }

        .back-button:hover {
            background-color: #5a6268;
        }

        a.title-link {
            color: #007bff;
            text-decoration: none;
            font-weight: bold;
        }

        a.title-link:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/views/layout/header.jsp" />

    <div class="container">
        <c:if test="${userRole == 'ADMIN'}">
            <p class="back-link"><a href="<c:url value='/movies'/>" class="back-button">내 영화 관리페이지로 돌아가기</a></p>
        </c:if> 
        <hr>

        <c:if test="${searchPerformed}">
            <c:if test="${not empty param.error && param.error == 'detailNotFound'}">
                <p class="error-message">선택하신 영화의 상세 정보를 가져오거나 등록할 수 없었습니다.</p>
            </c:if>

            <h2>"${query}" 검색 결과</h2>
            <c:if test="${empty apiMovies}">
                <p class="no-results">검색 결과가 없습니다. 다른 키워드로 검색해보세요.</p>
            </c:if>

            <c:if test="${not empty apiMovies}">
                <table class="movie-table">
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
                                            <img src="${apiMovie.posterPath}" alt="${apiMovie.title} 포스터" class="movie-poster" />
                                        </c:when>
                                        <c:otherwise>
                                            <img src="<c:url value='/resources/images/movies/256px-No-Image-Placeholder.png'/>" alt="기본 포스터" class="movie-poster" />
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <a href="<c:url value='/movies/api-external-detail?imdbId=${apiMovie.apiId}'/>" class="title-link">
                                        ${apiMovie.title}
                                    </a>
                                </td>
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
                                            N/A
                                        </c:when>
                                        <c:otherwise>
                                            <fmt:formatNumber value="${apiMovie.violence_score_avg}" pattern="#0.0" />
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>${fn:substring(apiMovie.overview, 0, 30)}...</td>
                                <c:if test="${userRole == 'ADMIN'}">
                                    <td>${apiMovie.apiId}</td>
                                    <td>
                                        <form action="<c:url value='/movies/import-api-detail'/>" method="post" class="action-form">
                                            <input type="hidden" name="imdbId" value="${apiMovie.apiId}" />
                                            <button type="submit" class="action-button">이 영화 등록</button>
                                        </form>
                                    </td>
                                </c:if>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:if>
        </c:if>
    </div>

    <jsp:include page="/WEB-INF/views/layout/footer.jsp" />
</body>
</html>