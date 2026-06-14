<%-- admin/bannerMovieManage.jsp (7-24 오후12:41 추가 된 코드) --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>추천 영화 관리</title>
    <link rel="stylesheet" href="<c:url value='/resources/css/layout.css'/>">
    <style>
        body {
            background: #f5f6f8;
        }
        .container {
            max-width: 1080px;
            margin: 32px auto;
            padding: 24px;
            background-color: #fff;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        }
        .manage-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: 16px;
            margin-bottom: 24px;
        }
        h2 {
            color: #333;
            margin: 0 0 8px;
        }
        .manage-header p {
            margin: 0;
            color: #6c757d;
        }
        .manage-actions {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
            justify-content: flex-end;
        }
        .manage-actions a {
            display: inline-flex;
            align-items: center;
            min-height: 38px;
            padding: 0 14px;
            border: 1px solid #ced4da;
            border-radius: 6px;
            color: #495057;
            text-decoration: none;
            background: #fff;
        }
        .message {
            padding: 10px;
            margin-bottom: 15px;
            border-radius: 5px;
            text-align: center;
            font-weight: bold;
        }
        .success-message {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        .error-message {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        .section-box {
            border: 1px solid #eee;
            padding: 20px;
            margin-bottom: 18px;
            border-radius: 8px;
            background-color: #f9f9f9;
        }
        .section-box h3 {
            margin-top: 0;
            margin-bottom: 15px;
            color: #555;
            border-bottom: 1px solid #eee;
            padding-bottom: 10px;
        }
        .section-title-line {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 10px;
        }
        .section-count {
            color: #6c757d;
            font-size: 0.9rem;
            font-weight: normal;
        }
        .movie-search-form {
            margin: 0 0 14px;
        }
        .movie-search-row {
            display: flex;
            gap: 10px;
            align-items: center;
        }
        .movie-search-row input {
            flex: 1;
            min-width: 0;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
        }
        .movie-search-row button,
        .candidate-add-button {
            padding: 10px 20px;
            background-color: #007bff;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            transition: background-color 0.3s ease;
            vertical-align: middle;
        }
        .movie-search-row button:hover,
        .candidate-add-button:hover {
            background-color: #0056b3;
        }
        .page-button {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-height: 40px;
            padding: 0 14px;
            border: 1px solid #6c757d;
            border-radius: 4px;
            color: #495057;
            background: #fff;
            text-decoration: none;
            white-space: nowrap;
        }
        .candidate-list {
            display: grid;
            gap: 10px;
            margin-top: 12px;
        }
        .candidate-item {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 6px;
            background: #fff;
        }
        .candidate-info {
            display: flex;
            align-items: center;
            gap: 12px;
            min-width: 0;
        }
        .candidate-info img {
            width: 48px;
            height: 68px;
            object-fit: cover;
            border-radius: 4px;
            background: #e9ecef;
            flex: 0 0 auto;
        }
        .candidate-title {
            font-weight: 700;
            color: #333;
        }
        .candidate-meta {
            margin-top: 4px;
            color: #6c757d;
            font-size: 0.9rem;
        }
        .candidate-item form {
            margin: 0;
            flex: 0 0 auto;
        }
        .current-movies ul {
            list-style: none;
            padding: 0;
        }
        .current-movies li {
            background-color: #fff;
            border: 1px solid #ddd;
            padding: 12px;
            margin-bottom: 10px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 12px;
            border-radius: 4px;
        }
        .recommended-movie-info {
            display: flex;
            align-items: center;
            gap: 12px;
            min-width: 0;
        }
        .recommended-movie-info img {
            width: 52px;
            height: 74px;
            object-fit: cover;
            border-radius: 4px;
            background: #e9ecef;
            flex: 0 0 auto;
        }
        .recommended-movie-title {
            font-weight: bold;
            color: #333;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }
        .recommended-movie-meta {
            margin-top: 4px;
            color: #6c757d;
            font-size: 0.9rem;
        }
        .current-movies li form {
            margin: 0;
            display: inline-block;
            flex: 0 0 auto;
        }
        .current-movies li button {
            background-color: #dc3545;
            color: white;
            padding: 8px 15px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            transition: background-color 0.3s ease;
        }
        .current-movies li button:hover {
            background-color: #c82333;
        }
        @media (max-width: 640px) {
            .container {
                margin: 16px;
                padding: 18px;
            }
            .manage-header,
            .movie-search-row,
            .candidate-item,
            .current-movies li {
                flex-direction: column;
                align-items: stretch;
            }
            .manage-actions {
                justify-content: flex-start;
            }
            .current-movies li button {
                width: 100%;
            }
            .candidate-add-button {
                width: 100%;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="manage-header">
            <div>
                <h2>추천 영화 관리</h2>
                <p>홈 화면에 보여줄 영화를 직접 고릅니다.</p>
            </div>
            <div class="manage-actions">
                <a href="<c:url value='/movies'/>">영화 목록으로</a>
                <a href="<c:url value='/'/>">홈으로</a>
            </div>
        </div>

        <c:if test="${not empty successMessage}">
            <div class="message success-message">${successMessage}</div>
        </c:if>
        <c:if test="${not empty errorMessage}">
            <div class="message error-message">${errorMessage}</div>
        </c:if>

        <div class="section-box">
            <h3>추천 영화 추가</h3>
            <form action="<c:url value='/admin/banner-movies'/>" method="get" class="movie-search-form">
                <div class="movie-search-row">
                    <input type="text" name="keyword" value="${keyword}" placeholder="제목, 감독, 장르, 등급 검색" />
                    <button type="submit">검색</button>
                    <a href="<c:url value='/admin/banner-movies'/>" class="page-button">초기화</a>
                </div>
            </form>
            <div class="candidate-list">
                <c:choose>
                    <c:when test="${not empty candidateMovies}">
                        <c:forEach var="movie" items="${candidateMovies}">
                            <c:set var="candidatePosterSrc">
                                <c:choose>
                                    <c:when test="${not empty movie.posterPath and movie.posterPath ne 'N/A'}">
                                        <c:choose>
                                            <c:when test="${fn:startsWith(movie.posterPath, 'http://') or fn:startsWith(movie.posterPath, 'https://')}">
                                                ${movie.posterPath}
                                            </c:when>
                                            <c:when test="${fn:startsWith(movie.posterPath, '/resources/')}">
                                                ${pageContext.request.contextPath}${movie.posterPath}
                                            </c:when>
                                            <c:otherwise>
                                                https://image.tmdb.org/t/p/w342${movie.posterPath}
                                            </c:otherwise>
                                        </c:choose>
                                    </c:when>
                                    <c:otherwise>
                                        ${pageContext.request.contextPath}/resources/images/movies/256px-No-Image-Placeholder.png
                                    </c:otherwise>
                                </c:choose>
                            </c:set>
                            <div class="candidate-item">
                                <div class="candidate-info">
                                    <img src="${candidatePosterSrc}" alt="${movie.title} 포스터">
                                    <div>
                                        <div class="candidate-title">${movie.title}</div>
                                        <div class="candidate-meta">
                                            ${movie.year}
                                            <c:if test="${not empty movie.director}">
                                                · ${movie.director}
                                            </c:if>
                                            <c:if test="${not empty movie.rated}">
                                                · ${movie.rated}
                                            </c:if>
                                        </div>
                                        <c:if test="${not empty movie.genre}">
                                            <div class="candidate-meta">${movie.genre}</div>
                                        </c:if>
                                    </div>
                                </div>
                                <form action="<c:url value='/admin/banner-movies/add'/>" method="post">
                                    <input type="hidden" name="movieId" value="${movie.id}">
                                    <input type="hidden" name="keyword" value="${keyword}">
                                    <button type="submit" class="candidate-add-button">추가</button>
                                </form>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <p>추가할 영화가 없습니다.</p>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <div class="section-box">
            <h3 class="section-title-line">
                <span>현재 추천 영화</span>
                <span class="section-count">${fn:length(currentAdminBannerMovies)}개</span>
            </h3>
            <c:choose>
                <c:when test="${not empty currentAdminBannerMovies}">
                    <ul class="current-movies">
                        <c:forEach var="movie" items="${currentAdminBannerMovies}">
                            <li>
                                <div class="recommended-movie-info">
                                    <c:if test="${not empty movie.posterPath}">
                                        <img src="${movie.posterPath}" alt="${movie.title} 포스터">
                                    </c:if>
                                    <div>
                                        <div class="recommended-movie-title">${movie.title}</div>
                                        <div class="recommended-movie-meta">
                                            ${movie.year}
                                            <c:if test="${not empty movie.rated}">
                                                · ${movie.rated}
                                            </c:if>
                                        </div>
                                    </div>
                                </div>
                                <form action="<c:url value='/admin/banner-movies/delete'/>" method="post" onsubmit="return confirm('정말로 이 영화를 추천 목록에서 삭제하시겠습니까?');">
                                    <input type="hidden" name="movieId" value="${movie.id}">
                                    <button type="submit">삭제</button>
                                </form>
                            </li>
                        </c:forEach>
                    </ul>
                </c:when>
                <c:otherwise>
                    <p>현재 수동 추천 영화로 등록된 영화가 없습니다.</p>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</body>
</html>
