<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<html>
<head>
    <title>영화 목록</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<c:url value='/resources/css/layout.css'/>">
    <style>
        body {
            background-color: #f8f9fa;
            color: #495057;
        }
        .container-fluid {
            padding: 40px;
        }
        .section-header {
            border-bottom: 2px solid #e9ecef;
            padding-bottom: 1rem;
            margin-bottom: 2rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .section-header h1 {
            color: #343a40;
            font-weight: 600;
            margin-bottom: 0;
        }
        .admin-links a {
            margin-left: 1rem;
            font-size: 1rem;
            color: #6c757d;
            text-decoration: none;
            transition: color 0.2s;
        }
        .admin-links a:hover {
            color: #495057;
            text-decoration: underline;
        }
        .table-container {
            background-color: #ffffff;
            border-radius: 10px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
        }
        .table {
            --bs-table-bg: #ffffff;
            --bs-table-hover-bg: #f8f9fa;
            width: 100%;
            margin-bottom: 0;
        }
        .table th, .table td {
            vertical-align: middle;
            word-wrap: break-word;
            padding: 8px;
            text-align: left;
        }
        .table th {
            background-color: #e9ecef;
            color: #495057;
            font-weight: 600;
            white-space: nowrap;
        }
        .table td a {
            color: #0d6efd;
            text-decoration: none;
        }
        .table td a:hover {
            text-decoration: underline;
        }
        .movie-poster-thumb {
            width: 80px;
            height: auto;
            border-radius: 5px;
            object-fit: cover;
        }
        .btn-action {
            padding: 5px 8px;
            font-size: 0.875rem;
            border-radius: 5px;
            margin-right: 2px;
            width: auto;
        }
        .btn-edit {
            background-color: #87D5AA;
            border-color: #ffffff;
            color: #fff;
        }
        .btn-delete {
            background-color: #dc3545;
            border-color: #dc3545;
            color: #fff;
        }
        .btn-warning-link {
            background-color: #ffc107;
            border-color: #ffc107;
            color: #000;
        }
        .alert {
            border-radius: 8px;
        }
        .no-data-cell {
            text-align: center;
            padding: 20px;
            color: #888;
            font-style: italic;
        }
        .link-group {
            display: flex;
            align-items: center;
            gap: 1rem;
        }

        .table td, .table th {
            min-width: 80px;
        }
        .table td:not(:nth-child(8)) {
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        .table td:nth-child(2) { max-width: 150px; }
        .table td:nth-child(8) {
            max-width: 250px;
            white-space: normal;
        }
        .table td:nth-child(10) { text-align: center; }

        .admin-controls-container {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 5px;
        }
        .admin-controls-container .btn-action,
        .admin-controls-container form {
            margin: 0 !important;
        }
    </style>
</head>
<body class="bg-light">

<jsp:include page="/WEB-INF/views/layout/header.jsp" />

<div class="container-fluid">
    <div class="section-header">
        <h1>영화 목록</h1>
        <c:if test="${userRole == 'ADMIN'}">
            <div class="link-group">
                <a href="<c:url value='/movies/new'/>" class="btn btn-sm btn-outline-secondary">새 영화 등록</a>
                <a href="<c:url value='/admin/banner-movies'/>" class="btn btn-sm btn-outline-secondary">추천 영화 관리</a>
                <a href="<c:url value='/admin/warnings/all'/>" class="btn btn-sm btn-outline-secondary">전체 주의 요소 관리</a>
            </div>
        </c:if>
    </div>

    <c:if test="${not empty param.error}">
        <div class="alert alert-danger" role="alert">
            ${param.error == 'notFound' ? '요청하신 영화를 찾을 수 없습니다.' : (param.error == 'movieNotFound' ? '영화 정보를 찾을 수 없거나 API 호출에 실패했습니다.' : '알 수 없는 오류가 발생했습니다.')}
        </div>
    </c:if>
    <c:if test="${not empty param.status && param.status == 'registered'}">
        <div class="alert alert-success" role="alert">
            API에서 영화 정보가 성공적으로 등록되었습니다!
        </div>
    </c:if>

    <div class="table-responsive table-container">
        <table class="table table-striped table-hover">
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
                    <th>TMDb ID</th>
                    <c:if test="${userRole == 'ADMIN'}">
                        <th class="text-center">관리</th>
                    </c:if>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="movie" items="${movies}">
                    <tr>
                        <td>
                            <c:set var="posterSrc">
                                <c:choose>
                                    <c:when test="${not empty movie.posterPath and movie.posterPath ne 'N/A'}">
                                        <c:choose>
                                            <c:when test="${fn:startsWith(movie.posterPath, 'http://') or fn:startsWith(movie.posterPath, 'https://')}">
                                                ${movie.posterPath}
                                            </c:when>
                                            <c:otherwise>
                                                ${pageContext.request.contextPath}${movie.posterPath}
                                            </c:otherwise>
                                        </c:choose>
                                    </c:when>
                                    <c:otherwise>
                                        ${pageContext.request.contextPath}/resources/images/movies/256px-No-Image-Placeholder.png
                                    </c:otherwise>
                                </c:choose>
                            </c:set>
                            <img src="${posterSrc}" alt="${movie.title} 포스터" class="movie-poster-thumb" />
                        </td>
                        <td>
                            <a href="<c:url value='/movies/${movie.id}'/>">${movie.title}</a>
                        </td>
                        <td>${movie.director}</td>
                        <td>${movie.year}</td>
                        <td>${movie.genre}</td>
                        <td>
                            <c:choose>
                                <c:when test="${movie.rating == 0.0}">N/A</c:when>
                                <c:otherwise><fmt:formatNumber value="${movie.rating}" pattern="#0.0" /></c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                            <c:choose>
                                <c:when test="${movie.violence_score_avg == 0.0}">N/A</c:when>
                                <c:otherwise><fmt:formatNumber value="${movie.violence_score_avg}" pattern="#0.0" /></c:otherwise>
                            </c:choose>
                        </td>
                        <td>${fn:substring(movie.overview, 0, 30)}...</td>
                        <td>${movie.apiId}</td>
                        <c:if test="${userRole == 'ADMIN'}">
                            <td>
                                <div class="admin-controls-container">
                                    <a href="<c:url value='/movies/${movie.id}/edit'/>" class="btn btn-sm btn-edit btn-action">수정</a>
                                    <a href="<c:url value='/admin/warnings/${movie.id}' />" class="btn btn-sm btn-warning-link btn-action">주의요소</a>
                                    <form action="<c:url value='/movies/${movie.id}/delete'/>" method="post" onsubmit="return confirm('정말로 이 영화를 삭제하시겠습니까?');" style="display:inline-block;">
                                        <button type="submit" class="btn btn-sm btn-delete btn-action">삭제</button>
                                    </form>
                                </div>
                            </td>
                        </c:if>
                    </tr>
                </c:forEach>
                <c:if test="${empty movies}">
                    <tr>
                        <td colspan="${userRole == 'ADMIN' ? '10' : '9'}" class="no-data-cell">등록된 영화가 없습니다.</td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>
</div>
<jsp:include page="/WEB-INF/views/layout/footer.jsp" />

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>